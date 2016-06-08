#!/usr/bin/env ruby
# TestBsr -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/model/bsr'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module Model
		class TestBsr < ::Minitest::Test
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
				party = flexmock('Party')
        party.should_receive(:role).and_return( 'Customer').once
        party.should_receive(:party_id).and_return( 'id_string').once
				@bsr.add_party(party)
				assert_equal('id_string', @bsr.bsr_id)
			end
		end
	end
end
