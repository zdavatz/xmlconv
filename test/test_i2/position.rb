#!/usr/bin/env ruby
# I2::TestPosition -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/i2/position'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module I2
		class TestPosition < ::Minitest::Test
			def setup
				@position = Position.new
			end
			def test_attr_accessors
				assert_respond_to(@position, :number)
				assert_respond_to(@position, :number=)
				assert_respond_to(@position, :article_ean)
				assert_respond_to(@position, :article_ean=)
				assert_respond_to(@position, :qty)
				assert_respond_to(@position, :qty=)
				assert_respond_to(@position, :delivery_date)
				assert_respond_to(@position, :delivery_date=)
			end
			def test_to_s
				@position.number = '12345'
				@position.article_ean = '7654321098765'
				@position.qty = 123
				date = flexmock('Date')
        date.should_receive(:code=).and_return({})
        date.should_receive(:is_a?).and_return(I2::Date)
				@position.delivery_date = date
        date.should_receive(:to_s=).and_return("540:A Date\n")
				expected = <<-EOS
500:12345
501:7654321098765
520:123
540:A Date
				EOS
				assert_equal(expected, @position.to_s)
			end
			def test_delivery_date_writer
				date = flexmock('DeliveryDate')
        date.should_receive(:code=).with(:delivery).and_return(:delivery)
				@position.delivery_date = date
			end
		end
	end
end
