#!/usr/bin/env ruby
# Util::TestPollingManager -- xmlconv2 -- 29.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/polling_manager'
require 'mock'

module XmlConv
	module Util
		class PollingManager
			CONFIG_PATH = File.expand_path('data/polling.yaml', 
				File.dirname(__FILE__))
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
				File.open(PollingManager::CONFIG_PATH, 'w') { |fh|
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
					expected = File.expand_path('data/xml', File.dirname(__FILE__))
					assert_equal(expected, source.directory)
					assert_equal('BddI2', source.writer)
					assert_equal('http://user:pass@foo.bar.baz', source.destination)
					block = block3
				}
				block1 = Proc.new { |source|
					assert_instance_of(PollingMission, source)
					assert_equal('I2Bdd', source.reader)
					expected = File.expand_path('data/i2', File.dirname(__FILE__))
					assert_equal(expected, source.directory)
					assert_equal('BddXml', source.writer)
					assert_equal('http://example.com:12345', source.destination)
					block = block2
				}
				block = block1
				@polling.load_sources { |source|
					block.call(source)
				}
			end
			def test_file_paths
				file2 = File.expand_path('file2.txt', @dir)
				File.open(file2, 'w') { |fh| fh << "File 2\n" }
				assert_equal([@file1, file2], @polling.file_paths(@dir).sort)
			end
			def test_poll
				source = Mock.new('Source')
				source.__next(:directory) { @dir }
				source.__next(:reader) { 'Reader' }
				source.__next(:writer) { 'Writer' }
				source.__next(:destination) { 'http://foo.bar.baz:2345' }
				@sys.__next(:execute) { |transaction|
					assert_instance_of(Util::Transaction, transaction)
					assert_equal("File 1\n", transaction.input)
					assert_equal('file:' << @file1, transaction.origin)
					assert_equal('Reader', transaction.reader)
					assert_equal('Writer', transaction.writer)
					dest = transaction.destination
					assert_instance_of(Util::DestinationHttp, dest)
					assert_equal('http://foo.bar.baz:2345', dest.uri.to_s)
				}
				@polling.poll(source)
				source.__verify
			end
			def test_destination
				dest = @polling.destination('http://foo:bar@baz.com')
				assert_instance_of(Util::DestinationHttp, dest)
				assert_equal('baz.com', dest.host)
				assert_instance_of(URI::HTTP, dest.uri)
				assert_equal('http://foo:bar@baz.com', dest.uri.to_s)
			end
		end
	end
end
