#!/usr/bin/env ruby
# I2::TestDate -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/i2/date'
require 'minitest/autorun'

module XmlConv
	module I2
		class TestDate < ::Minitest::Test
			def test_from_date
				a_date = Date.new(1975, 8, 21)
				date = I2::Date.from_date(a_date)
				assert_equal(a_date, date)
			end
			def test_to_s__order_order
				date = I2::Date.new(1975, 8, 21)
        date.level = :order
        date.code = :order
				expected = <<-EOS
300:4
301:19750821
				EOS
				assert_equal(expected, date.to_s)
			end
			def test_to_s__position_delivery
				date = I2::Date.new(1975, 8, 21)
        date.level = :position
				date.code = :delivery
				expected = <<-EOS
540:2
541:19750821
				EOS
				assert_equal(expected, date.to_s)
			end
			def test_to_s__position_delivery
				date = I2::Date.new(1975, 8, 21)
        date.level = :order
				date.code = :delivery
				expected = <<-EOS
300:2
301:19750821
				EOS
				assert_equal(expected, date.to_s)
			end
		end
	end
end
