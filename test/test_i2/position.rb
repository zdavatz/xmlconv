#!/usr/bin/env ruby
# I2::TestPosition -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'i2/position'
require 'mock'

module XmlConv
	module I2
		class TestPosition < Test::Unit::TestCase
			class ToSMock < Mock
				def is_a?(klass)
					true
				end
				def to_s
					true
				end
			end
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
				date = ToSMock.new('Date')
				date.__next(:code=) {}
				@position.delivery_date = date
				date.__next(:is_a?) { |klass| 
					assert_equal(I2::Date, klass)
					true
				}
				date.__next(:to_s) { "540:A Date\n" }
				expected = <<-EOS
500:12345
501:7654321098765
520:123
540:A Date
				EOS
				assert_equal(expected, @position.to_s)
			end
			def test_delivery_date_writer
				date = Mock.new('DeliveryDate')
				date.__next(:code=) { |code| 
					assert_equal(:delivery, code)
				}
				@position.delivery_date = date
				date.__verify
			end
		end
	end
end
