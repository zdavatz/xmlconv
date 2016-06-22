#!/usr/bin/env ruby
# Util::PollingManager -- xmlconv2 -- 29.06.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'uri'
require 'yaml'
require 'xmlconv/util/destination'
require 'xmlconv/util/mail'
require 'xmlconv/util/transaction'
require 'net/pop'
require 'mail'

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
        puts "PopMission starts polling host #{@host}:#{@port} u: #{@user} pw: #{@pass}"
        options = {
                          :address    => @host,
                          :port       => @port,
                          :user_name  => @user,
                          :password   => @pass,
                          :enable_ssl => true
          }
        ::Mail.defaults do retriever_method :pop3, options  end
        all_mails = ::Mail.delivery_method.is_a?(::Mail::TestMailer) ? ::Mail::TestMailer.deliveries : ::Mail.all
        all_mails.each do |mail|
            begin
              poll_message(mail, &block)
            ensure
              time = Time.now
              name = sprintf("%s.%s.%s", @user, time.strftime("%Y%m%d%H%M%S"), time.usec)
              FileUtils.mkdir_p(@backup_dir)
              path = File.join(@backup_dir, name)
              File.open(path, 'w') { |fh| fh.puts(mail) }
              mail.mark_for_delete = true
              # mail.delete # Not necessary with gem mail, as delete_after_find is set to true by default
            end
        end
      end
      def poll_message(message, &block)
        if(message.multipart?)
          message.parts.each do |part|
            poll_message(part, &block)
          end
        elsif(/text\/xml/.match(message.content_type))
          filtered_transaction(message.decoded, sprintf('pop3:%s@%s:%s', @user, @host, @port), &block)
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
        Net::FTP.open(uri.host, uri.user, uri.password) do |ftp|
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
        Net::SFTP.start(uri.host, uri.user,
                        :user_known_hosts_file => CONFIG.ssh_known_hosts_file,
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
      rescue NoMethodError
        ## prevent polling error notification for intermittent connection problems
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
          begin
            source.poll { |transaction|
              @system.execute(transaction)
            }
          rescue Exception => e
            subject = 'XmlConv2 - Polling-Error'
            body = [e.class, e.message].concat(e.backtrace).join("\n")
            Util::Mail.notify source.error_recipients, subject, body
          end
				}
			end
		end
	end
end
