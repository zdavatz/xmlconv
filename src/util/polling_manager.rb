#!/usr/bin/env ruby
# Util::PollingManager -- xmlconv2 -- 29.06.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'uri'
require 'yaml'
require 'util/destination'
require 'util/transaction'

module XmlConv
	module Util
		class PollingMission
			attr_accessor :directory, :reader, :writer, :destination
		end
		class PollingManager
			CONFIG_PATH = File.expand_path('../../etc/polling.yaml', 
				File.dirname(__FILE__))
			def initialize(system)
				@system = system
			end
			def destination(str)
				uri = URI.parse(str)
				case uri
				when URI::HTTP
					dest = DestinationHttp.new
					dest.uri = uri
					dest
				end
			end
			def load_sources(&block)
				file = File.open(self::class::CONFIG_PATH)
				YAML.load_documents(file, &block)
			ensure
				file.close
			end
			def file_paths(dir_path)
				Dir.entries(dir_path).collect { |entry|
					File.expand_path(entry, dir_path) unless(entry[0] == ?.)
				}.compact
			end
			def poll(source)
				file_paths(source.directory).each { |path|
					transaction = XmlConv::Util::Transaction.new
					transaction.input = File.read(path)
					transaction.origin = path
					transaction.reader = source.reader
					transaction.writer = source.writer
					transaction.destination = destination(source.destination)
					@system.execute(transaction)
				}
			end
			def poll_sources
				load_sources { |source|
					poll(source)
				}
			end
		end
	end
end
