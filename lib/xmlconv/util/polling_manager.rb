#!/usr/bin/env ruby
# Util::PollingManager -- xmlconv2 -- 29.06.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'uri'
require 'yaml'
require 'xmlconv/util/destination'
require 'xmlconv/util/transaction'
require 'net/pop'
require 'rmail'

module XmlConv
	module Util
    class Mission
      attr_accessor :reader, :writer, :destination, :error_recipients,
        :debug_recipients, :backup_dir, :partner
    end
		class PollingMission < Mission
			attr_accessor :directory, :glob_pattern
			def file_paths
        path = File.expand_path(@glob_pattern || '*', @directory)
				Dir.glob(path).collect { |entry|
					File.expand_path(entry, @directory)
				}.compact
			end
			def poll
				file_paths.each { |path|
					begin
						transaction = XmlConv::Util::Transaction.new
						transaction.input = File.read(path)
						transaction.partner = @partner
						transaction.origin = 'file:' << path
						transaction.reader = @reader
						transaction.writer = @writer
						transaction.destination = Destination.book(@destination)
						transaction.debug_recipients = @debug_recipients
						transaction.error_recipients = @error_recipients
						yield transaction
          rescue Exception => e
            puts e
            puts e.backtrace
					ensure
						FileUtils.mkdir_p(@backup_dir)
						FileUtils.mv(path, @backup_dir)
					end
				}
			end
		end
    class PopMission < Mission
      attr_accessor :host, :port, :user, :pass, :content_type
      def poll(&block)
        Net::POP3.start(@host, @port, @user, @pass) { |pop|
          pop.each_mail { |mail|
            source = mail.pop
            begin
              poll_message(RMail::Parser.read(source), &block)
            ensure
              time = Time.now
              name = sprintf("%s.%s.%s", @account, 
                             time.strftime("%Y%m%d%H%M%S"), time.usec)
              FileUtils.mkdir_p(@backup_dir)
              path = File.join(@backup_dir, name)
              File.open(path, 'w') { |fh| fh.puts(source) }
              mail.delete
            end
          }
        }
      end
      def poll_message(message, &block)
        if(message.multipart?)
          message.each_part { |part|
            poll_message(part, &block)
          }
        elsif(@content_type.match(message.header.content_type('text/plain')))
          transaction = XmlConv::Util::Transaction.new
          transaction.input = message.body
          transaction.partner = @partner
          transaction.origin = sprintf('pop3:%s@%s:%s', @user, @host, @port)
          transaction.reader = @reader
          transaction.writer = @writer
          transaction.destination = Destination.book(@destination)
          transaction.debug_recipients = @debug_recipients
          transaction.error_recipients = @error_recipients
          block.call(transaction)
        end
      end
    end
		class PollingManager
			def initialize(system)
				@system = system
			end
			def load_sources(&block)
				file = File.open(CONFIG.polling_file)
				YAML.load_documents(file) { |mission|
					path = File.expand_path(mission.directory, CONFIG.project_root)
					mission.directory = path
					block.call(mission)
				}
			ensure
				file.close if(file)
			end
			def poll_sources
				load_sources { |source|
          source.poll { |transaction|
            @system.execute(transaction)
          }
				}
			end
		end
	end
end
