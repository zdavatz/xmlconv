#!/usr/bin/env ruby
# Model::TestInvoice -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/invoice'
require 'mock'

module XmlConv
	module Model
		class TestInvoice < Test::Unit::TestCase
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
			def test_add_item
				item = Mock.new
				@invoice.add_item(item)	
				assert_equal([item], @invoice.items)
				item.__verify
			end
			def test_add_delivery_id
				@invoice.add_delivery_id('Domain', 'Id')
				assert_equal(['Domain', 'Id'], @invoice.delivery_id)
			end
			def test_add_party__customer
				party = Mock.new('Customer')
				party.__next(:role) { 'Customer' }
				@invoice.add_party(party)
				assert_equal(party, @invoice.customer)
				assert_equal([party], @invoice.parties)
				party.__verify
			end
			def test_add_party__seller
				party = Mock.new('Seller')
				party.__next(:role) { 'Seller' }
				@invoice.add_party(party)
				assert_equal(party, @invoice.seller)
				assert_equal([party], @invoice.parties)
				party.__verify
			end
		end
	end
end
