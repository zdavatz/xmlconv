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
        :debug_recipients, :backup_dir, :partner, :postprocs
      def create_transaction
        transaction = XmlConv::Util::Transaction.new
        transaction.domain = @domain
        transaction.partner = @partner
        transaction.reader = @reader
        transaction.writer = @writer
        transaction.debug_recipients = @debug_recipients
        transaction.error_recipients = @error_recipients
        transaction.postprocs = @postprocs
        transaction.destination = Destination.book(@destination)
        transaction
      end
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
        @directory = File.expand_path(@directory, CONFIG.project_root)
				file_paths.each { |path|
					begin
						transaction = create_transaction
						transaction.input = File.read(path)
						transaction.origin = 'file:' << path
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
        Net::POP3.start(@host, @port || 110, @user, @pass) { |pop|
          pop.each_mail { |mail|
            source = mail.pop
            begin
              ## work around a bug in RMail::Parser that cannot deal with
              ## RFC-2822-compliant CRLF..
              source.gsub!(/\r\n/, "\n")
              poll_message(RMail::Parser.read(source), &block)
            ensure
              time = Time.now
              name = sprintf("%s.%s.%s", @user, 
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
          transaction = create_transaction
          transaction.input = message.decode
          transaction.origin = sprintf('pop3:%s@%s:%s', @user, @host, @port)
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
