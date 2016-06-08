#!/usr/bin/env ruby
# I2::TestOrder -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/i2/order'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module I2
		class TestOrder < ::Minitest::Test
			def setup
				@order = Order.new
			end
			def test_attr_accessors
				assert_respond_to(@order, :sender_id)
				assert_respond_to(@order, :sender_id=)
				assert_respond_to(@order, :delivery_id)
				assert_respond_to(@order, :delivery_id=)
			end
			def test_attr_readers
				assert_respond_to(@order, :addresses)
			end
			def test_add_address
				assert_equal([], @order.addresses)
				address = flexmock
				@order.add_address(address)
				assert_equal([address], @order.addresses)
			end
			def test_add_date
				assert_equal([], @order.dates)
				date = flexmock
				@order.add_date(date)
				assert_equal([date], @order.dates)
			end
			def test_add_position
				assert_equal([], @order.positions)
				position = flexmock
				@order.add_position(position)
				assert_equal([position], @order.positions)
			end
			def test_to_s
				@order.sender_id = 'Sender'
				@order.delivery_id = 'DeliveryId'
				address1 = flexmock('Address1')
        address1.should_receive(:to_s).and_return("200:An Address\n")
				@order.add_address(address1)
				address2 = flexmock('Address2')
        address2.should_receive(:to_s).and_return("200:Another Address\n")
				@order.add_address(address2)
				date1 = flexmock('Date1')
        date1.should_receive(:to_s).and_return("300:A Date\n").once
				@order.add_date(date1)
				date2 = flexmock('Date2')
        date2.should_receive(:to_s).and_return("300:Another Date\n").once
				@order.add_date(date2)
				pos1 = flexmock('Position1')
        pos1.should_receive(:to_s).and_return( "500:A Position\n").once
				@order.add_position(pos1)
				pos2 = flexmock('Position2')
        pos2.should_receive(:to_s).and_return( "500:Another Position\n").once
				@order.add_position(pos2)
				expected = <<-EOS
100:Sender
101:DeliveryId
200:An Address
200:Another Address
237:61
300:A Date
300:Another Date
500:A Position
500:Another Position
				EOS
				assert_equal(expected, @order.to_s)
			end
		end
	end
end
