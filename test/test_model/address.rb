#!/usr/bin/env ruby
# TestAddress -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/address'

module XmlConv
	module Model
		class TestAddress < Test::Unit::TestCase
			def setup
				@address = Address.new
			end
			def test_attr_accessors
				assert_respond_to(@address, :city)
				assert_respond_to(@address, :city=)
				assert_respond_to(@address, :zip_code)
				assert_respond_to(@address, :zip_code=)
			end
			def test_attr_readers
				assert_respond_to(@address, :lines)
			end
			def test_add_line
				@address.add_line('line 1')
				assert_equal(['line 1'], @address.lines)
				@address.add_line('line 2')
				assert_equal(['line 1', 'line 2'], @address.lines)
			end
		end
	end
end
