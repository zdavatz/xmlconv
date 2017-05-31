#!/usr/bin/env ruby
# Util::TestPollingManager -- xmlconv2 -- 29.06.2004 -- hwyss@ywesee.com
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/util/polling_manager'
require 'config'
require 'minitest/autorun'
require 'flexmock/minitest'

Mail.defaults do
  delivery_method :test
end

module XmlConv
	module Util
    TestData = File.join(File.expand_path('..', File.dirname(__FILE__)), 'data')
    class TestPollingMission < ::Minitest::Test
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
			def test_poll_filtered__match
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
        @mission.filter = "^File\\s*\\d+"
				@mission.poll { |transaction|
          flunk "Block should not be called in Filtered Transaction"
        }
        assert(true)
			end
			def test_poll_filtered__no_match
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
        @mission.filter = "^File\\s*2"
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
    class TestPopMission < ::Minitest::Test
      def setup
        ::Mail::TestMailer.deliveries.clear
        ::Mail.defaults do delivery_method :test end
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
        options = { :from =>  'you@you.com', }
        ::Mail.defaults do delivery_method :test, options end
        mail = ::Mail.read(File.join(TestData, 'simple_email.txt'))
        mail.deliver
        mail = ::Mail.read(File.join(TestData, 'sandoz.xundart@bbmb.ch.20110524001038.928592'))
        mail.deliver
        nr_messages = 2
        assert_equal(nr_messages, ::Mail::TestMailer.deliveries.length)
        counter = 0
        @mission.poll do |transaction|
          counter += 1
          assert_instance_of(Util::Transaction, transaction)
          next if /testuser@localhost/.match(transaction.origin)
          expected = %(<?xml version=\"1.0\"?>
<foo>
  <bar/>
</foo>
)
          assert_equal(expected, transaction.input)
          assert_equal("pop3:testuser@localhost:#{@mission.port}",
                        transaction.origin)
          assert_equal('Reader', transaction.reader)
          assert_equal('Writer', transaction.writer)
          dest = transaction.destination
          assert_instance_of(Util::DestinationHttp, dest)
          assert_equal('http://foo.bar.baz:2345', dest.uri.to_s)
        end
        assert_equal(nr_messages, counter,  "poll-block should have been called exactly #{nr_messages} times")
      end
      def teardown
        @popserver.close
      end
    end
		class TestPollingManager < ::Minitest::Test
			def setup
				@sys = flexmock('System')
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
        super
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
      def test_poll__general_error
        mission1 = flexmock(YAML.load <<-EOS)
--- !ruby/object:XmlConv::Util::PollingMission
reader: I2Bdd
directory: "./test/test_util/data/i2"
writer: BddXml
destination: "http://example.com:12345"
error_recipients:
 - test@ywesee.com
        EOS
        mission2 = flexmock(YAML.load <<-EOS)
--- !ruby/object:XmlConv::Util::PollingMission
directory: "./test/test_util/data/xml"
destination: "http://user:pass@foo.bar.baz"
writer: BddI2
reader: XmlBdd
error_recipients:
 - test@ywesee.com
        EOS

        flexmock(YAML).should_receive(:load_documents).and_return do |mission, block|
          block.call(mission1)
          block.call(mission2)
        end
        executed_mission2 = false
        mission1.should_receive(:poll).times(1).and_return do
          raise "Something went wrong (simulated Error)"
        end
        mission2.should_receive(:poll).times(1).and_return do
          executed_mission2 = true
          assert true # passed the test: the second mission was executed
        end
        flexmock(Util::Mail).should_receive(:notify).times(1)\
          .and_return do |recipients, subject, body|
          assert_equal [ 'test@ywesee.com' ], recipients
          assert_equal 'XmlConv2 - Polling-Error', subject
          assert_equal <<-EOS, body[0,52]
RuntimeError
Something went wrong (simulated Error)
          EOS
        end
        @polling.poll_sources
        assert executed_mission2, "Polling choked on Error"
      end
		end
	end
end
