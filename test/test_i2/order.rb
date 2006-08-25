#!/usr/bin/env ruby
# I2::TestOrder -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/i2/order'
require 'mock'

module XmlConv
	module I2
		class TestOrder < Test::Unit::TestCase
			class ToSMock < Mock
				def to_s
					true
				end
			end
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
				address = Mock.new
				@order.add_address(address)
				assert_equal([address], @order.addresses)
				address.__verify
			end
			def test_add_date
				assert_equal([], @order.dates)
				date = Mock.new
				@order.add_date(date)
				assert_equal([date], @order.dates)
				date.__verify
			end
			def test_add_position
				assert_equal([], @order.positions)
				position = Mock.new
				@order.add_position(position)
				assert_equal([position], @order.positions)
				position.__verify
			end
			def test_to_s
				@order.sender_id = 'Sender'
				@order.delivery_id = 'DeliveryId'
				address1 = ToSMock.new('Address1')
				@order.add_address(address1)
				address1.__next(:to_s) { "200:An Address\n" }
				address2 = ToSMock.new('Address2')
				@order.add_address(address2)
				address2.__next(:to_s) { "200:Another Address\n" }
				date1 = ToSMock.new('Date1')
				@order.add_date(date1)
				date1.__next(:to_s) { "300:A Date\n" }
				date2 = ToSMock.new('Date2')
				@order.add_date(date2)
				date2.__next(:to_s) { "300:Another Date\n" }
				pos1 = ToSMock.new('Position1')
				@order.add_position(pos1)
				pos1.__next(:to_s) { "500:A Position\n" }
				pos2 = ToSMock.new('Position2')
				@order.add_position(pos2)
				pos2.__next(:to_s) { "500:Another Position\n" }
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
				address1.__verify
				address2.__verify
				date1.__verify
				date2.__verify
				pos1.__verify
				pos2.__verify
			end
		end
	end
end
