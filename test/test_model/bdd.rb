#!/usr/bin/env ruby
# TestBdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/bdd'
require 'mock'

module XmlConv
	module Model
		class TestBdd < Test::Unit::TestCase
			def setup
				@bdd = Bdd.new
			end
			def test_attr_accessors
				assert_respond_to(@bdd, :bsr)
				assert_respond_to(@bdd, :bsr=)
			end
			def test_attr_readers
				assert_respond_to(@bdd, :deliveries)
			end
			def test_add_delivery
				delivery = Mock.new('Delivery')
				assert_equal([], @bdd.deliveries)
				@bdd.add_delivery(delivery)
				assert_equal([delivery], @bdd.deliveries)
			end
		end
	end
end
