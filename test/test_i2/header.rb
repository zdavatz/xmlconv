#!/usr/bin/env ruby
# I2::TestHeader -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'i2/header'

module XmlConv
	module I2
		class TestHeader < Test::Unit::TestCase
			def setup
				@header = Header.new
			end
			def test_attr_accessors
				assert_respond_to(@header, :recipient_id)
				assert_respond_to(@header, :recipient_id=)
				assert_respond_to(@header, :filename)
				assert_respond_to(@header, :filename=)
			end
			def test_to_s
				@header.recipient_id = 'Recipient'
				@header.filename = 'filename.dat'
				expected = <<-EOS
001:Recipient
002:ORDERX
003:220
010:filename.dat
				EOS
				assert_equal(expected, @header.to_s)
			end
			def test_filename
				expected = Time.now.strftime("#{@header.recipient_id}_%Y%m%d%H%M%S")
				assert_match(/#{expected}\d{3}.dat/, @header.filename)
			end
		end
	end
end
