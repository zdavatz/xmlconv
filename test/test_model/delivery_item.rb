#!/usr/bin/env ruby
# TestDeliveryItem -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/delivery_item'

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
			end
			def test_add_id
				assert_equal({}, @item.ids)
				@item.add_id('ET-NUMMER', 'et_number')
				assert_equal('et_number', @item.et_nummer_id)
				assert_equal({'ET-NUMMER'	=>	'et_number'}, @item.ids)
			end
		end
	end
end
