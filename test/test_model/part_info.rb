#!/usr/bin/env ruby
# Model::TestPartInfo -- xmlconv2 -- 23.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/model/part_info'
require 'minitest/autorun'

module XmlConv
	module Model
		class TestPartInfo < ::Minitest::Test
			def setup
				@part_info = PartInfo.new
			end
			def test_attr_accessors
				assert_respond_to(@part_info, :dimension)
				assert_respond_to(@part_info, :dimension=)
				assert_respond_to(@part_info, :value)
				assert_respond_to(@part_info, :value=)
			end
		end
	end
end
