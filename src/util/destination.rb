#!/usr/bin/env ruby
# Destination -- xmlconv2 -- 08.06.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'uri'
require 'odba'
require 'net/http'

module XmlConv
	module Util
		class Destination
			include ODBA::Persistable
			attr_accessor :path
			attr_reader :uri, :status
			STATUS_COMPARABLE = {
				:pending_pickup	=>	10,	
				:picked_up			=>	20,	
				:http_ok				=>	20
			}
			def initialize
				@status = :open
			end
			def deliver(delivery)
				raise 'Abstract Method deliver called in Destination'
			end
			def update_status
			end
			def status_comparable
				self::class::STATUS_COMPARABLE[@status].to_i				
			end
			def forget_credentials!
			end
		end
		class DestinationDir < Destination
			attr_reader :filename
			def deliver(delivery)
        do_deliver(delivery)
        @status = :pending_pickup
				odba_store
      end
      def do_deliver(delivery)
        if(delivery.is_a?(Array))
          delivery.each { |part| do_deliver(part) }
        else
          FileUtils.mkdir_p(@path)
          @filename = delivery.filename
          path = File.expand_path(@filename, @path)
          File.open(path, 'w') { |fh| fh << delivery.to_s }
        end
			end
			def update_status
				if(@status == :pending_pickup \
					&& !File.exist?(File.expand_path(@filename.to_s, @path)))
					@status = :picked_up
					odba_store
				end
			end
			def uri
				URI.parse("file:#{File.expand_path(@filename.to_s, @path)}")
			end
		end
		class DestinationHttp < Destination
			HTTP_CLASS = Net::HTTP # replaceable for testing purposes
			HTTP_HEADERS = {
				'content-type'	=>	'text/xml',
			}
			def initialize
				super
				@uri = URI.parse('http:/')
			end
			def deliver(delivery)
        do_deliver(delivery)
      ensure
        forget_credentials!
      end
      def do_deliver(delivery)
        if(delivery.is_a?(Array))
           worst_status = ''
           delivery.each { |part| 
             do_deliver(part) 
             ## bogostatus: assume that the more information in the string, 
             ##             the worse the status is (ok < not found)
             ##             rationale: DTSTTCPW
             if(@status.to_s > worst_status.to_s)
               worst_status = @status
             end
           }
           @status = worst_status
        else
          self.class::HTTP_CLASS.start(@uri.host, @uri.port) { |http|
            request = Net::HTTP::Post.new(@uri.path, HTTP_HEADERS)
            if(@uri.user || @uri.password)
              request.basic_auth(@uri.user, @uri.password)
            end
            response = http.request(request, delivery.to_s)	
            status_str = response.message.downcase.gsub(/\s+/, "_")
            @status = "http_#{status_str}".intern
          }
        end
			end
			def forget_credentials!
				@uri = URI::HTTP.new(@uri.scheme, nil, @uri.host, @uri.port, 
					@uri.registry, @uri.path, @uri.opaque, @uri.query, @uri.fragment)
			end
			def host
				@uri.host
			end
			def host=(str)
				@uri.host = str
			end
			def path
				@uri.path if(@uri)
			end
			def path=(str)
				@uri.path = str if(@uri)
			end
			def uri=(uri)
				if(uri.is_a?(String))
					@uri = URI.parse(uri)
				else
					@uri = uri
				end
			end
		end
	end
end
