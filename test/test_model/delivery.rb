#!/usr/bin/env ruby
# TestDelivery -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/delivery'
require 'mock'

module XmlConv
	module Model
		class TestDelivery < Test::Unit::TestCase
			def setup
				@delivery = Delivery.new
			end
			def test_attr_accessors
				assert_respond_to(@delivery, :customer)
				assert_respond_to(@delivery, :customer=)
				assert_respond_to(@delivery, :bsr)
				assert_respond_to(@delivery, :bsr=)
			end
			def test_attr_readers
				assert_respond_to(@delivery, :items)
				assert_respond_to(@delivery, :parties)
				assert_respond_to(@delivery, :ids)
				assert_respond_to(@delivery, :customer_id)
			end
			def test_bsr_id
				bsr = Mock.new('BSR')
				bsr.__next(:bsr_id) { 'id_string' } 
				assert_nil(@delivery.bsr_id)
				@delivery.bsr = bsr
				assert_equal('id_string', @delivery.bsr_id)
				bsr.__verify
			end
			def test_add_party
				party = Mock.new('Customer')
				party.__next(:role) { 'Customer' }
				@delivery.add_party(party)
				assert_equal(party, @delivery.customer)
				assert_equal([party], @delivery.parties)
				party.__verify
			end
			def test_add_item
				item = Mock.new
				@delivery.add_item(item)	
				assert_equal([item], @delivery.items)
				item.__verify
			end
		end
	end
end
