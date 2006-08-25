#!/usr/bin/env ruby
# I2::TestDocument -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/i2/document'
require 'mock'

module XmlConv
	module I2
		class TestDocument < Test::Unit::TestCase
			class ToSMock < Mock
				def to_s
					true
				end
			end
			def setup
				@document = I2::Document.new
			end
			def test_attr_accessors
				assert_respond_to(@document, :header)
				assert_respond_to(@document, :header=)
			end
			def test_add_order
				assert_equal([], @document.orders)
				order = Mock.new
				@document.add_order(order)
				assert_equal([order], @document.orders)
				order.__verify
			end
			def test_to_s
				header = ToSMock.new('Header')
				@document.header = header
				header.__next(:to_s) { "000:A Header\n" }
				order1 = ToSMock.new('Order1')
				@document.add_order(order1)
				order1.__next(:to_s) { "100:An Order\n" }
				order2 = ToSMock.new('Order2')
				@document.add_order(order2)
				order2.__next(:to_s) { "100:Another Order\n" }
				expected = <<-EOS
000:A Header
100:An Order
100:Another Order
				EOS
				assert_equal(expected, @document.to_s)
				header.__verify
				order1.__verify
				order2.__verify
			end
			def test_filename
				header = Mock.new
				header.__next(:filename) { 'result.dat' }
				@document.header = header
				assert_equal('result.dat', @document.filename)
				header.__verify
			end
		end
	end
end
