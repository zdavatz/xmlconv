#!/usr/bin/env ruby
# TestBsr -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/bsr'
require 'mock'

module XmlConv
	module Model
		class TestBsr < Test::Unit::TestCase
			def setup
				@bsr = Bsr.new
			end
			def test_attr_readers
				assert_respond_to(@bsr, :parties)
			end
			def test_attr_accessors
				assert_respond_to(@bsr, :timestamp)
				assert_respond_to(@bsr, :timestamp=)
				assert_respond_to(@bsr, :noun)
				assert_respond_to(@bsr, :noun=)
				assert_respond_to(@bsr, :verb)
				assert_respond_to(@bsr, :verb=)
			end
			def test_bsr_id
				party = Mock.new('Party')
				party.__next(:role) { 'Customer' }
				party.__next(:party_id) { 'id_string' }
				@bsr.add_party(party)
				assert_equal('id_string', @bsr.bsr_id)
				party.__verify
			end
		end
	end
end
