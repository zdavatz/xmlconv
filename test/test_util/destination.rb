#!/usr/bin/env ruby
# TestDestination -- xmlconv2 -- 08.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/destination'
require 'mock'

module XmlConv
	module Util
		class TestDestination < Test::Unit::TestCase
			def setup
				@destination = Destination.new
			end
			def test_attr_accessors
				assert_respond_to(@destination, :path)
				assert_respond_to(@destination, :path=)
			end
			def test_attr_readers
				assert_respond_to(@destination, :uri)
				assert_respond_to(@destination, :status)
				assert_respond_to(@destination, :update_status)
			end
			def test_deliver
				delivery = Mock.new('Delivery')
				assert_raises(RuntimeError) { 
					@destination.deliver(delivery)
				}
			end
		end
		class TestDestinationDir < Test::Unit::TestCase
			def setup
				@destination = DestinationDir.new
				@target_dir = File.expand_path('data/destination', 
					File.dirname(__FILE__))
			end
			def teardown
				if(File.exist?(@target_dir))
					FileUtils.rm_r(@target_dir)
				end
			end
			def test_attr_readers
				assert_respond_to(@destination, :filename)
			end
			def test_deliver
				cache = Mock.new('Cache')
				ODBA.cache_server = cache
				cache.__next(:store) { |obj|
					assert_equal(@destination, obj)
				}
				delivery = Mock.new('Delivery')
				delivery.__next(:filename) { 'test_file.dat' }
				if(File.exist?(@target_dir))
					FileUtils.rm_r(@target_dir)
				end
				@destination.path = @target_dir
				@destination.deliver(delivery)
				target_file = File.expand_path('test_file.dat', @target_dir)
				assert(File.exist?(@target_dir), "Target Directory was not created")
				assert(File.exist?(target_file), "Target File was not written")
				assert_equal(delivery.to_s, File.read(target_file))
				assert_equal('test_file.dat', @destination.filename)
				assert_equal(:pending_pickup, @destination.status)
				cache.__verify
				delivery.__verify
			end
			def test_uri
				@destination.path = '/foo/bar/baz'
				assert_equal("file:/foo/bar/baz", @destination.uri)
				@destination.instance_variable_set('@filename', 'test_file.dat')
				assert_equal("file:/foo/bar/baz/test_file.dat", @destination.uri)
			end
			def test_status
				cache = Mock.new('Cache')
				ODBA.cache_server = cache
				cache.__next(:store) { |obj|
					assert_equal(@destination, obj)
				}
				assert_equal(:open, @destination.status)
				@destination.update_status
				assert_equal(:open, @destination.status)
				@destination.instance_variable_set('@status', :pending_pickup)
				@destination.instance_variable_set('@filename', 'no_such.file')
				assert_equal(:pending_pickup, @destination.status)
				@destination.update_status
				assert_equal(:picked_up, @destination.status)
				@destination.update_status
				assert_equal(:picked_up, @destination.status)
				cache.__verify
			end
			def test_status_comparable
				assert_equal(0, @destination.status_comparable)
				@destination.instance_variable_set('@status', :pending_pickup)
				assert_equal(10, @destination.status_comparable)
				@destination.instance_variable_set('@status', :picked_up)
				assert_equal(20, @destination.status_comparable)
			end
		end
	end
end
