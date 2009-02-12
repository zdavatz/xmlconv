#!/usr/bin/env ruby
# Destination -- xmlconv2 -- 08.06.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'uri'
require 'odba'
require 'net/http'
require 'net/ftp'
require 'tempfile'

module XmlConv
	module Util
		class Destination
			include ODBA::Persistable
			attr_accessor :path, :status
			attr_reader :uri
			STATUS_COMPARABLE = {
				:pending_pickup	=>	10,	
				:picked_up			=>	20,	
        :bbmb_ok        =>  20,
				:http_ok				=>	20,
        :ftp_ok         =>  20,
			}
      def Destination.book(str, tmp=nil)
				uri = URI.parse(str)
        tmp = URI.parse(tmp) if tmp
				case uri
				when URI::HTTP
					DestinationHttp.new(uri)
        when URI::FTP
          DestinationFtp.new(uri, tmp)
				else
					DestinationDir.new(uri)
				end
      end
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
      def sanitize(str)
        str.to_s.gsub(/[^a-zA-Z0-9 ]/, '').gsub(' ', '+')
      end
			def forget_credentials!
			end
		end
		class DestinationDir < Destination
			attr_reader :filename
      def initialize(uri = URI.parse('/'))
        @path = uri.path
        super()
      end
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
          path = File.expand_path(sanitize(@filename), @path)
          File.open(path, 'w') { |fh| fh << delivery.to_s }
        end
			end
			def update_status
				if(@status == :pending_pickup \
					&& !File.exist?(File.expand_path(sanitize(@filename), @path)))
					@status = :picked_up
					odba_store
				end
			end
			def uri
				URI.parse("file:#{File.expand_path(sanitize(@filename), @path)}")
			end
		end
    class RemoteDestination < Destination
      attr_accessor :transport
      def deliver(delivery)
        do_deliver(delivery)
      ensure
        forget_credentials!
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
    class DestinationFtp < RemoteDestination
			def initialize(uri = URI.parse('ftp:/'), tmp = nil)
				super()
        @tmp = tmp
				@uri = uri
        @transport = Net::FTP
			end
      def do_deliver(delivery)
        @transport.open(@uri.host, @uri.user, @uri.password) { |conn|
          conn.chdir(@uri.path)
          deliver_to_connection(conn, delivery)
        }
      end
      def deliver_to_connection(connection, delivery, idx=nil)
        if(delivery.is_a?(Array))
          delivery.each_with_index { |part, idx| 
            deliver_to_connection(connection, part, idx) 
          }
        else
          fh = Tempfile.new('xmlconv')
          fh.puts(delivery)
          fh.flush
          target = delivery.filename
          if(idx)
            target = sprintf("%03i_%s", idx, target)
          end
          if(@tmp)
            tmp = File.join(@tmp.path, target)
            connection.puttextfile(fh.path, tmp)
            connection.rename(tmp, target)
          else
            connection.puttextfile(fh.path, target)
          end
          fh.close!
          @status = :ftp_ok
        end
      end
    end
		class DestinationHttp < RemoteDestination
			HTTP_HEADERS = {
				'content-type'	=>	'text/xml',
			}
			def initialize(uri = URI.parse('http:/'))
				super()
				@uri = uri
        @transport = Net::HTTP
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
          @transport.start(@uri.host, @uri.port) { |http|
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
		end
	end
end
