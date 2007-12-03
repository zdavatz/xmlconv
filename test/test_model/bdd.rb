#!/usr/bin/env ruby
# TestBdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/model/bdd'
require 'flexmock'

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
				assert_respond_to(@bdd, :invoices)
			end
			def test_add_delivery
				delivery = FlexMock.new('Delivery')
				assert_equal([], @bdd.deliveries)
				@bdd.add_delivery(delivery)
				assert_equal([delivery], @bdd.deliveries)
			end
			def test_add_invoice
				invoice = FlexMock.new('Invoice')
				assert_equal([], @bdd.invoices)
				@bdd.add_invoice(invoice)
				assert_equal([invoice], @bdd.invoices)
			end
      def test_invoiced_amount
        assert_equal(0, @bdd.invoiced_amount)
        invoice = FlexMock.new
        price = FlexMock.new
        @bdd.invoices.push(invoice, invoice) 
        invoice.should_receive(:get_price)\
          .times(4).and_return { |purpose|
          assert_equal('SummePositionen', purpose)
          price
        }
        price.should_receive(:amount)\
          .times(1).and_return { '123.45' }
        assert_equal(246.90, @bdd.invoiced_amount)
        @bdd.deliveries.push(invoice) 
        assert_equal(246.90, @bdd.invoiced_amount)
      end
		end
	end
end
