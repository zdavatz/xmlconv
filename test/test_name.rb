#!/usr/bin/env ruby
# TestName -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/name'

module XmlConv
	module Model
		class TestName < Test::Unit::TestCase
			def setup
				@name = Name.new
			end
			def test_attr_accessors
				assert_respond_to(@name, :first)
				assert_respond_to(@name, :first=)
				assert_respond_to(@name, :last)
				assert_respond_to(@name, :last=)
			end
			def test_to_s
				@name.first = 'First'
				assert_equal('First', @name.to_s)
				@name.last = 'Last'
				assert_equal('First Last', @name.to_s)
			end
		end
	end
end
