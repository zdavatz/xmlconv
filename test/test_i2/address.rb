#!/usr/bin/env ruby
# I2::TestAddress -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/i2/address'
require 'minitest/autorun'

module XmlConv
	module I2
		class TestAddress < ::Minitest::Test
			def setup
				@address = I2::Address.new
			end
			def test_attr_accessors
				assert_respond_to(@address, :code)
				assert_respond_to(@address, :code=)
				assert_respond_to(@address, :party_id)
				assert_respond_to(@address, :party_id=)
				assert_respond_to(@address, :name1)
				assert_respond_to(@address, :name1=)
				assert_respond_to(@address, :name2)
				assert_respond_to(@address, :name2=)
				assert_respond_to(@address, :street1)
				assert_respond_to(@address, :street1=)
				assert_respond_to(@address, :street2)
				assert_respond_to(@address, :street2=)
				assert_respond_to(@address, :city)
				assert_respond_to(@address, :city=)
				assert_respond_to(@address, :zip_code)
				assert_respond_to(@address, :zip_code=)
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
				@address.party_id = 'BuyerId'
				@address.name1 = 'Company Name'
				@address.name2 = 'Employee Name'
				expected = <<-EOS
201:BY
202:BuyerId
220:Company Name
221:Employee Name
				EOS
				assert_equal(expected, @address.to_s)
			end
			def test_to_s3
				@address.code = :employee
				@address.party_id = 'Delivery Code'
				@address.name1 = 'Name1'
				@address.name2 = 'Name2'
				@address.street1 = 'Street1'
				@address.street2 = 'Street2'
				@address.city = 'City'
				@address.zip_code = 'ZipCode'
				expected = <<-EOS
201:EP
202:Delivery Code
220:Name1
221:Name2
222:Street1
223:City
225:ZipCode
226:Street2
				EOS
				assert_equal(expected, @address.to_s)
			end
		end
	end
end
