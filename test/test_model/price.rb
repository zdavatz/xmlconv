#!/usr/bin/env ruby
# TestPrice -- xmlconv2 -- 21.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/price'

module XmlConv
	module Model
		class TestPrice < Test::Unit::TestCase
			def setup
				@price = Price.new
			end
			def test_attr_accessors
				assert_respond_to(@price, :purpose)
				assert_respond_to(@price, :purpose=)
				assert_respond_to(@price, :amount)
				assert_respond_to(@price, :amount=)
			end
		end
	end
end
