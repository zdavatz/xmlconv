#!/usr/bin/env ruby
# I2::TestAddress -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'i2/address'

module XmlConv
	module I2
		class TestAddress < Test::Unit::TestCase
			def setup
				@address = I2::Address.new
			end
			def test_attr_accessors
				assert_respond_to(@address, :code)
				assert_respond_to(@address, :code=)
				assert_respond_to(@address, :buyer_id)
				assert_respond_to(@address, :buyer_id=)
			end
			def test_to_s1
				@address.code = :delivery
				@address.name1 = 'Name1'
				@address.name2 = 'Name2'
				@address.street1 = 'Street1'
				@address.street2 = 'Street2'
				@address.city = 'City'
				@address.zip_code = 'ZipCode'
				expected = <<-EOS
201:DP
220:Name1
221:Name2
222:Street1
223:City
225:ZipCode
226:Street2
				EOS
				assert_equal(expected, @address.to_s)
			end
			def test_to_s2
				@address.buyer_id = 'BuyerId'
				expected = <<-EOS
201:BY
202:BuyerId
				EOS
				assert_equal(expected, @address.to_s)
			end
		end
	end
end
