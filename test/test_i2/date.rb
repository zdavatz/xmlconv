#!/usr/bin/env ruby
# I2::TestDate -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'i2/date'

module XmlConv
	module I2
		class TestDate < Test::Unit::TestCase
			def test_from_date
				a_date = Date.new(1975, 8, 21)
				date = I2::Date.from_date(a_date)
				assert_equal(a_date, date)
			end
			def test_to_s1
				# NOTE
				# DTSTTCPW here and now is to allow only two possibilities for 
				# I2::Date:
				# Order-Date on the Order-Level (300:4\n301:strftime) and 
				# Delivery-Date on the Position-Level (540:2\n540:strftime)
				# This code is likely to change.
				date = I2::Date.new(1975, 8, 21)
				expected = <<-EOS
300:4
301:19750821
				EOS
				assert_equal(expected, date.to_s)
			end
			def test_to_s2
				# NOTE
				# DTSTTCPW here and now is to allow only two possibilities for 
				# I2::Date:
				# Order-Date on the Order-Level (300:4\n301:strftime) and 
				# Delivery-Date on the Position-Level (540:2\n540:strftime)
				# This code is likely to change.
				date = I2::Date.new(1975, 8, 21)
				date.code = :delivery
				expected = <<-EOS
540:2
541:19750821
				EOS
				assert_equal(expected, date.to_s)
			end
		end
	end
end
