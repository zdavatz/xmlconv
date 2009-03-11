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
        :debug_recipients, :backup_dir, :partner, :postprocs, :filter, 
        :tmp_destination, :arguments
      def create_transaction
        transaction = XmlConv::Util::Transaction.new
        transaction.domain = @domain
        transaction.partner = @partner
        transaction.reader = @reader
        transaction.writer = @writer
        transaction.debug_recipients = @debug_recipients
        transaction.error_recipients = @error_recipients
        transaction.postprocs = @postprocs
        transaction.destination = Destination.book(@destination, @tmp_destination)
        transaction.arguments = [@arguments].flatten.compact
        transaction
      end
      def filtered_transaction(src, origin, &block)
        unless(@filter && Regexp.new(@filter).match(src))
          transaction = create_transaction
          transaction.input = src
          transaction.origin = origin
          block.call(transaction)
        end
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
            filtered_transaction(File.read(path), 'file:' << path) { |transaction|
              yield transaction
            }
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
          src = message.decode
          filtered_transaction(src, sprintf('pop3:%s@%s:%s', @user, @host, @port),
                               &block)
        end
      end
    end
    class FtpMission < Mission
      attr_accessor :origin, :glob_pattern
      def file_names(ftp)
        pattern = @glob_pattern || '*'
        ftp.nlst.select do |name| File.fnmatch pattern, name end
      end
      def poll(&block)
        uri = URI.parse(@origin)
        origin_dir = "ftp://#{uri.user}@#{uri.host}#{uri.path}"
        require 'net/ftp'
        Net::FTP.start(uri.host, uri.user, uri.password) do |ftp|
          ftp.chdir uri.path
          file_names(ftp).each do |name|
            begin
              origin = File.join origin_dir, name
              FileUtils.mkdir_p(@backup_dir)
              target = File.join(@backup_dir, name)
              ftp.gettextfile name, target
              filtered_transaction File.read(target), origin do |trans|
                block.call trans
              end
            rescue Exception => e
              puts e
              puts e.backtrace
            ensure
              ftp.delete name
            end
          end
        end
      end
    end
    class SftpMission < Mission
      attr_accessor :origin, :glob_pattern
      def file_names(sftp, uri)
        pattern = @glob_pattern || '*'
        sftp.dir.entries(uri.path).collect do |entry|
          name = entry.name
          name if File.fnmatch pattern, name
        end.compact
      end
      def poll(&block)
        uri = URI.parse(@origin)
        require 'net/sftp'
        Net::SFTP.open(uri.host, uri.user,
                       :keys => CONFIG.ssh_identities) do |sftp|
          file_names(sftp, uri).each do |name|
            begin
              path = File.join uri.path, name
              origin = File.join @origin, name
              source = sftp.file.open path do |fh| fh.read end
              filtered_transaction source, origin do |trans|
                block.call trans
              end
            rescue Exception => e
              puts e
              puts e.backtrace
            ensure
              FileUtils.mkdir_p(@backup_dir)
              File.open File.join(@backup_dir, name), 'w' do |fh|
                fh.puts source
              end
              sftp.remove! path
            end
          end
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
