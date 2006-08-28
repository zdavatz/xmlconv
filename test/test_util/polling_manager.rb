#!/usr/bin/env ruby
# Util::TestPollingManager -- xmlconv2 -- 29.06.2004 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/polling_manager'
require 'mock'
require 'rexml/document'
require 'config'

module XmlConv
	module Util
    class TestPollingMission < Test::Unit::TestCase
      def setup
        @mission = PollingMission.new
				@dir = File.expand_path('data/i2', 
					File.dirname(__FILE__))
				FileUtils.mkdir_p(@dir)
				@file1 = File.expand_path('file1.txt', @dir)
				File.open(@file1, 'w') { |fh| fh << "File 1\n" }
      end
			def teardown
				FileUtils.rm_rf(@dir) 
			end
			def test_file_paths
        @mission.directory = @dir
				file2 = File.expand_path('file2.txt', @dir)
				File.open(file2, 'w') { |fh| fh << "File 2\n" }
				assert_equal([@file1, file2], @mission.file_paths.sort)
        @mission.glob_pattern = "file2*"
				assert_equal([file2], @mission.file_paths.sort)
			end
			def test_poll
				backup_dir = File.expand_path('../data', File.dirname(__FILE__))
				@mission.directory = @dir
				@mission.glob_pattern = '*'
        @mission.partner = 'Partner'
				@mission.reader = 'Reader'
				@mission.writer = 'Writer'
				@mission.destination = 'http://foo.bar.baz:2345'
				@mission.debug_recipients = nil
				@mission.error_recipients = nil
				@mission.backup_dir = backup_dir
				@mission.poll { |transaction|
					assert_instance_of(Util::Transaction, transaction)
					assert_equal("File 1\n", transaction.input)
					assert_equal('file:' << @file1, transaction.origin)
					assert_equal('Reader', transaction.reader)
					assert_equal('Writer', transaction.writer)
					dest = transaction.destination
					assert_instance_of(Util::DestinationHttp, dest)
					assert_equal('http://foo.bar.baz:2345', dest.uri.to_s)
        }
			end
    end
    class TestPopMission < Test::Unit::TestCase
      def setup
        @popserver = TCPServer.new('127.0.0.1', 0)
        addr = @popserver.addr 
        @mission = PopMission.new
        @mission.host = 'localhost'
        @mission.port = addr.at(1)
        @mission.user = "testuser"
        @mission.pass = "test"
        @mission.content_type = "text/xml"
        @datadir = File.expand_path('data', File.dirname(__FILE__)) 
        @mission.backup_dir = File.join(@datadir, 'backup')
        @mission.destination = File.join(@datadir, 'destination')
        @mission.partner = 'Partner'
				@mission.reader = 'Reader'
				@mission.writer = 'Writer'
				@mission.destination = 'http://foo.bar.baz:2345'
				@mission.debug_recipients = nil
				@mission.error_recipients = nil
      end
      def teardown
        FileUtils.rm_r(@datadir)
      end
      def test_poll
        message = RMail::Message.new
        part1 = RMail::Message.new
        part1.header.add("content-type", 'text/plain')
        part1.body = "some senseless data"
        message.add_part(part1)

        part2 = RMail::Message.new
        part2.header.add("content-type", 'text/xml', nil, 
                         'encoding' => 'iso-8859-1')
        doc = REXML::Document.new("<foo><bar /></foo>")
        part2.body = doc.to_s
        message.add_part(part2)

        part3 = RMail::Message.new
        part3.header.add("content-type", 'text/plain')
        part3.body = "some more senseless data"
        message.add_part(part3)

        mail = message.to_s

        @server = Thread.new { 
          Thread.start(@popserver.accept) do |socket|
            socket.puts("+OK")
            while line = socket.gets
              case line[0,4]
              when "USER"
                assert_equal("USER testuser\r\n", line)
                socket.print("+OK\r\n")
              when "PASS"
                assert_equal("PASS test\r\n", line)
                socket.print("+OK\r\n")
              when "STAT"
                socket.print("+OK 1 1\r\n")
              when "LIST"
                socket.print("+OK\r\n")
                socket.print("1 #{mail.size}\r\n")
                socket.print(".\r\n")
              when "RETR"
                socket.print("+OK #{mail.size}\r\n")
                socket.print(mail)
                socket.print("\r\n.\r\n")
              when "QUIT"
                socket.print("+OK\r\n")
                break
              else
                socket.print("+OK\r\n")
              end
            end
            socket.close
          end
        }
        counter = 0
        @mission.poll { |transaction|
          counter += 1
 					assert_instance_of(Util::Transaction, transaction)
					assert_equal(doc.to_s, transaction.input)
					assert_equal("pop3:testuser@localhost:#{@mission.port}", 
                       transaction.origin)
					assert_equal('Reader', transaction.reader)
					assert_equal('Writer', transaction.writer)
					dest = transaction.destination
					assert_instance_of(Util::DestinationHttp, dest)
					assert_equal('http://foo.bar.baz:2345', dest.uri.to_s)
       }
       assert_equal(1, counter, 
                    "poll-block should have been called exactly once")
      end
      def teardown
        @popserver.close
      end
    end
		class TestPollingManager < Test::Unit::TestCase
			def setup
				@sys = Mock.new('System')
				@polling = PollingManager.new(@sys)
				@dir = File.expand_path('data/i2', 
					File.dirname(__FILE__))
				FileUtils.mkdir_p(@dir)
				@file1 = File.expand_path('file1.txt', @dir)
				File.open(@file1, 'w') { |fh| fh << "File 1\n" }
			end
			def teardown
				FileUtils.rm_rf(@dir) 
				@sys.__verify
			end
			def test_load_sources
				File.open(CONFIG.polling_file, 'w') { |fh|
					fh << <<-EOS
--- !ruby/object:XmlConv::Util::PollingMission
reader: I2Bdd
directory: "./test/test_util/data/i2"
writer: BddXml
destination: "http://example.com:12345"
--- !ruby/object:XmlConv::Util::PollingMission
directory: "./test/test_util/data/xml"
destination: "http://user:pass@foo.bar.baz"
writer: BddI2
reader: XmlBdd
				EOS
				}
				block = nil
				block3 = Proc.new { |source| 
					flunk "too many sources"
				}
				block2 = Proc.new { |source|
					assert_instance_of(PollingMission, source)
					assert_equal('XmlBdd', source.reader)
					assert_equal('./test/test_util/data/xml', source.directory)
					assert_equal('BddI2', source.writer)
					assert_equal('http://user:pass@foo.bar.baz', source.destination)
					block = block3
				}
				block1 = Proc.new { |source|
					assert_instance_of(PollingMission, source)
					assert_equal('I2Bdd', source.reader)
					assert_equal('./test/test_util/data/i2', source.directory)
					assert_equal('BddXml', source.writer)
					assert_equal('http://example.com:12345', source.destination)
					block = block2
				}
				block = block1
				@polling.load_sources { |source|
					block.call(source)
				}
			end
		end
	end
end
