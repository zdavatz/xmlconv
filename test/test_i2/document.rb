#!/usr/bin/env ruby
# I2::TestDocument -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/i2/document'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module I2
		class TestDocument < ::Minitest::Test
			def setup
				@document = I2::Document.new
			end
			def test_attr_accessors
				assert_respond_to(@document, :header)
				assert_respond_to(@document, :header=)
			end
			def test_add_order
				assert_equal([], @document.orders)
				order = flexmock
				@document.add_order(order)
				assert_equal([order], @document.orders)
			end
			def test_to_s
				header = flexmock('Header')
				@document.header = header
        header.should_receive(:to_s).and_return("000:A Header\n").once
				order1 = flexmock('Order1')
				@document.add_order(order1)
        order1.should_receive(:to_s).and_return("100:An Order\n").once
				order2 = flexmock('Order2')
				@document.add_order(order2)
        order2.should_receive(:to_s).and_return("100:Another Order\n").once
				expected = <<-EOS
000:A Header
100:An Order
100:Another Order
				EOS
				assert_equal(expected, @document.to_s)
			end
			def test_filename
				header = flexmock
        header.should_receive(:filename).and_return( 'result.dat').once
				@document.header = header
				assert_equal('result.dat', @document.filename)
			end
		end
	end
end
