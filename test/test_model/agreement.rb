#!/usr/bin/env ruby
# TestAgreement -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/agreement'

module XmlConv
	module Model
		class TestAgreement < Test::Unit::TestCase
			def setup
				@agreement = Agreement.new
			end
			def test_attr_accessors
				assert_respond_to(@agreement, :terms_cond)
				assert_respond_to(@agreement, :terms_cond=)
			end
		end
	end
end
