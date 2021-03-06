#!/usr/bin/env ruby
# TestAddress -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/model/address'
require 'minitest/autorun'

module XmlConv
	module Model
		class TestAddress < ::Minitest::Test
			def setup
				@address = Address.new
			end
			def test_attr_accessors
				assert_respond_to(@address, :city)
				assert_respond_to(@address, :city=)
				assert_respond_to(@address, :zip_code)
				assert_respond_to(@address, :zip_code=)
				assert_respond_to(@address, :country)
				assert_respond_to(@address, :country=)
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
