#!/usr/bin/env ruby
# TestDelivery -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/model/delivery'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module Model
		class TestDelivery < ::Minitest::Test
			def setup
				@delivery = Delivery.new
			end
			def test_attr_accessors
				assert_respond_to(@delivery, :customer)
				assert_respond_to(@delivery, :customer=)
				assert_respond_to(@delivery, :bsr)
				assert_respond_to(@delivery, :bsr=)
				assert_respond_to(@delivery, :agreement)
				assert_respond_to(@delivery, :agreement=)
				assert_respond_to(@delivery, :free_text)
				assert_respond_to(@delivery, :free_text=)
				assert_respond_to(@delivery, :status)
				assert_respond_to(@delivery, :status=)
				assert_respond_to(@delivery, :status_date)
				assert_respond_to(@delivery, :status_date=)
			end
			def test_attr_readers
				assert_respond_to(@delivery, :items)
				assert_respond_to(@delivery, :parties)
				assert_respond_to(@delivery, :ids)
				assert_respond_to(@delivery, :customer_id)
				assert_respond_to(@delivery, :prices)
			end
			def test_add_free_text
				assert_respond_to(@delivery, :add_free_text)
			end
			def test_bsr_id
				bsr = flexmock('BSR')
        bsr.should_receive(:bsr_id).and_return( 'id_string').once
				assert_nil(@delivery.bsr_id)
				@delivery.bsr = bsr
				assert_equal('id_string', @delivery.bsr_id)
			end
			def test_add_party__customer
				party = flexmock('Customer')
        party.should_receive(:role).and_return( 'Customer').once
				@delivery.add_party(party)
				assert_equal(party, @delivery.customer)
				assert_equal([party], @delivery.parties)
			end
			def test_add_party__seller
				party = flexmock('Seller')
        party.should_receive(:role).and_return( 'Seller').once
				@delivery.add_party(party)
				assert_equal(party, @delivery.seller)
				assert_equal([party], @delivery.parties)
			end
			def test_add_item
				item = flexmock
				@delivery.add_item(item)	
				assert_equal([item], @delivery.items)
			end
			def test_add_price
				assert_equal([], @delivery.prices)
				price = flexmock('BruttoPreis')
				@delivery.add_price(price)
				assert_equal([price], @delivery.prices)
			end
		end
	end
end
