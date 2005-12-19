#!/usr/bin/env ruby
# TestDestination -- xmlconv2 -- 08.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/destination'
require 'mock'

module XmlConv
	module Util
		class DestinationHttp < Destination
			HTTP_CLASS = Mock.new('DestinationHttp::HTTP_CLASS')
		end
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
			def test_forget_credentials
				assert_respond_to(@destination, :forget_credentials!)
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
				storage = Mock.new('Storage')
				storage.__next(:transaction) { |block|
					block.call
				}
				ODBA.storage = storage
				cache = Mock.new('Cache')
				ODBA.cache = cache
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
			ensure
				ODBA.storage = nil
				ODBA.cache = nil
			end
			def test_uri
				@destination.path = '/foo/bar/baz'
				assert_instance_of(URI::Generic, @destination.uri)
				assert_equal("file:/foo/bar/baz", @destination.uri.to_s)
				@destination.instance_variable_set('@filename', 'test_file.dat')
				assert_equal("file:/foo/bar/baz/test_file.dat", @destination.uri.to_s)
			end
			def test_status
				storage = Mock.new('Storage')
				storage.__next(:transaction) { |block|
					block.call
				}
				ODBA.storage = storage
				cache = Mock.new('Cache')
				ODBA.cache = cache
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
			ensure
				ODBA.storage = nil
				ODBA.cache = nil
			end
			def test_status_comparable
				assert_equal(0, @destination.status_comparable)
				@destination.instance_variable_set('@status', :pending_pickup)
				assert_equal(10, @destination.status_comparable)
				@destination.instance_variable_set('@status', :picked_up)
				assert_equal(20, @destination.status_comparable)
			end
		end
		class TestDestinationHttp < Test::Unit::TestCase
			class ToSMock < Mock
				def to_s
					true
				end
			end
			def setup
				@destination = DestinationHttp.new
			end
			def test_attr_accessors
				assert_respond_to(@destination, :path)
				assert_respond_to(@destination, :path=)
				assert_respond_to(@destination, :uri)
				assert_respond_to(@destination, :uri=)
				assert_respond_to(@destination, :host)
				assert_respond_to(@destination, :host=)
			end
			def test_path_writer
				assert_equal('http:/', @destination.uri.to_s)
				@destination.path = '/foo/bar'
				assert_equal('http:/foo/bar', @destination.uri.to_s)
			end
			def test_host_writer
				assert_equal('http:/', @destination.uri.to_s)
				@destination.host = 'www.example.org'
				assert_equal('http://www.example.org/', @destination.uri.to_s)
			end
			def test_uri_writer
				uri = URI.parse('http://www.example.org/foo/bar')
				assert_instance_of(URI::HTTP, @destination.uri)
				assert_equal('http:/', @destination.uri.to_s)
				@destination.uri = uri
				assert_instance_of(URI::HTTP, @destination.uri)
				assert_equal('http://www.example.org/foo/bar', @destination.uri.to_s)
				@destination.uri = 'http://www.example.com/foo/bar'
				assert_instance_of(URI::HTTP, @destination.uri)
				assert_equal('http://www.example.com/foo/bar', @destination.uri.to_s)
			end
			def test_deliver
				@destination.uri = 'http://testaccount:password@janico.ywesee.com:12345/test.rbx'
				http_session = Mock.new('HttpSession')
				delivery = ToSMock.new('Delivery')
				response = Mock.new('Response')
				response.__next(:message) { 'Status' }
				delivery.__next(:to_s) { 'The Delivery' }
				http_session.__next(:request) { |post_request, body| 
					assert_instance_of(Net::HTTP::Post, post_request)
					header = post_request.instance_variable_get('@header') 
					assert_equal(['text/xml'], header['content-type'])
					assert(header.include?('authorization'), "Authorization-Headers not sent")
					assert_equal('The Delivery', body)
					response
				}
				DestinationHttp::HTTP_CLASS.__next(:start) { |block, host, port| 
					assert_equal('janico.ywesee.com', host)
					assert_equal(12345, port)
					block.call(http_session)
				}
				@destination.deliver(delivery)
				assert_equal(:http_status, @destination.status)
				# When the delivery is delivered, forget username and Password
				uri = @destination.uri
				assert_nil(uri.user)
				assert_nil(uri.password)
				assert_equal('http://janico.ywesee.com:12345/test.rbx', uri.to_s)
				DestinationHttp::HTTP_CLASS.__verify
				http_session.__verify
				delivery.__verify
				response.__verify
			end
		end
	end
end
