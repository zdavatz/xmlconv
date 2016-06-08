#!/usr/bin/env ruby
# Model::TestInvoiceItem -- xmlconv2 -- 23.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
puts File.expand_path('../../lib', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/model/invoice_item'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module Model
		class TestInvoiceItem < ::Minitest::Test
			def setup
				@item = InvoiceItem.new
			end
			def test_attr_accessors
				assert_respond_to(@item, :line_no)
				assert_respond_to(@item, :line_no=)
				assert_respond_to(@item, :qty)
				assert_respond_to(@item, :qty=)
			end
			def test_attr_readers
				assert_respond_to(@item, :part_infos)
				assert_respond_to(@item, :ids)
				assert_respond_to(@item, :free_text)
			end
			def test_add_id
				assert_equal({}, @item.ids)
				@item.add_id('ET-NUMMER', 'et_number')
				assert_equal({'ET-NUMMER'	=>	'et_number'}, @item.ids)
			end
			def test_add_part_info
				info = flexmock('PartInfo')
				assert_equal([], @item.part_infos)
				@item.add_part_info(info)
				assert_equal([info], @item.part_infos)
			end
		end
	end
end
