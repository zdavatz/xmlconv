#!/usr/bin/env ruby
# TestDeliveryItem -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/model/delivery_item'
require 'mock'

module XmlConv
	module Model
		class TestDeliveryItem < Test::Unit::TestCase
			def setup
				@item = DeliveryItem.new
			end
			def test_attr_accessors
				assert_respond_to(@item, :line_no)
				assert_respond_to(@item, :line_no=)
				assert_respond_to(@item, :qty)
				assert_respond_to(@item, :qty=)
				assert_respond_to(@item, :delivery_date)
				assert_respond_to(@item, :delivery_date=)
			end
			def test_attr_readers
				assert_respond_to(@item, :ids)
				assert_respond_to(@item, :et_nummer_id)
				assert_respond_to(@item, :prices)
				assert_respond_to(@item, :free_text)
				assert_respond_to(@item, :part_infos)
			end
			def test_add_id
				assert_equal({}, @item.ids)
				@item.add_id('ET-NUMMER', 'et_number')
				assert_equal('et_number', @item.et_nummer_id)
				assert_equal({'ET-NUMMER'	=>	'et_number'}, @item.ids)
			end
			def test_add_price
				assert_equal([], @item.prices)
				price = Mock.new('BruttoPreis')
				@item.add_price(price)
				assert_equal([price], @item.prices)
			end
			def test_add_part_info
				info = Mock.new('PartInfo')
				assert_equal([], @item.part_infos)
				@item.add_part_info(info)
				assert_equal([info], @item.part_infos)
			end
		end
	end
end
