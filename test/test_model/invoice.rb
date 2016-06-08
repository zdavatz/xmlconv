#!/usr/bin/env ruby
# Model::TestInvoice -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/model/invoice'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module Model
		class TestInvoice < ::Minitest::Test
			def setup
				@invoice = Invoice.new
			end
			def test_attr_readers
				assert_respond_to(@invoice, :ids)
				assert_respond_to(@invoice, :items)
				assert_respond_to(@invoice, :parties)
				assert_respond_to(@invoice, :prices)
				assert_respond_to(@invoice, :delivery_id)
			end
			def test_attr_accessors
				assert_respond_to(@invoice, :free_text)
				assert_respond_to(@invoice, :free_text=)
				assert_respond_to(@invoice, :agreement)
				assert_respond_to(@invoice, :agreement=)
				assert_respond_to(@invoice, :status)
				assert_respond_to(@invoice, :status=)
				assert_respond_to(@invoice, :status_date)
				assert_respond_to(@invoice, :status_date=)
			end
			def test_add_free_text
				assert_respond_to(@invoice, :add_free_text)
			end
			def test_add_item
				item = flexmock
				@invoice.add_item(item)	
				assert_equal([item], @invoice.items)
			end
			def test_add_delivery_id
				@invoice.add_delivery_id('Domain', 'Id')
				assert_equal(['Domain', 'Id'], @invoice.delivery_id)
			end
			def test_add_party__customer
				party = flexmock('Customer')
        party.should_receive(:role).and_return( 'Customer').once
				@invoice.add_party(party)
				assert_equal(party, @invoice.customer)
				assert_equal([party], @invoice.parties)
			end
			def test_add_party__seller
				party = flexmock('Seller')
        party.should_receive(:role).and_return( 'Seller').once
				@invoice.add_party(party)
				assert_equal(party, @invoice.seller)
				assert_equal([party], @invoice.parties)
			end
		end
	end
end
