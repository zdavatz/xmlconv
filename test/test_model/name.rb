#!/usr/bin/env ruby
# TestName -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

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
				assert_respond_to(@name, :text)
				assert_respond_to(@name, :text=)
			end
			def test_to_s
				@name.first = 'First'
				assert_equal('First', @name.to_s)
				@name.last = 'Last'
				assert_equal('First Last', @name.to_s)
				@name.text = 'Text'
				assert_equal('First Text Last', @name.to_s)
			end
			def test_attr_writers
				assert_nil(@name.first)
				@name.first = nil
				assert_nil(@name.first)
				@name.first = 'first'
				assert_equal('first', @name.first)
				@name.first = ''
				assert_nil(@name.first)
				assert_nil(@name.last)
				@name.last = nil
				assert_nil(@name.last)
				@name.last = 'last'
				assert_equal('last', @name.last)
				@name.last = ''
				assert_nil(@name.last)
				assert_nil(@name.text)
				@name.text = nil
				assert_nil(@name.text)
				@name.text = 'text'
				assert_equal('text', @name.text)
				@name.text = ''
				assert_nil(@name.text)
			end
		end
	end
end
