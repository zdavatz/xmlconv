#!/usr/bin/env ruby
# Destination -- xmlconv2 -- 08.06.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'odba'

module XmlConv
	module Util
		class Destination
			include ODBA::Persistable
			attr_accessor :path
			attr_reader :uri, :status
			STATUS_COMPARABLE = {
				:pending_pickup	=>	10,	
				:picked_up			=>	20,	
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
		end
		class DestinationDir < Destination
			attr_reader :filename
			def deliver(delivery)
				FileUtils.mkdir_p(@path)
				@filename = delivery.filename
				path = File.expand_path(@filename, @path)
				@status = :pending_pickup
				File.open(path, 'w') { |fh| fh << delivery.to_s }
				odba_store
			end
			def update_status
				if(@status == :pending_pickup \
					&& !File.exist?(File.expand_path(@filename.to_s, @path)))
					@status = :picked_up
					odba_store
				end
			end
			def uri
				"file:#{File.expand_path(@filename.to_s, @path)}"
			end
		end
	end
end
