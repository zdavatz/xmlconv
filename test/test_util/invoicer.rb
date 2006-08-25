#!/usr/bin/env ruby
# Util::TestInvoicer -- xmlconv2 -- 03.08.2006 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/invoicer'
require 'flexmock'

module XmlConv
	module Util
		class TestInvoicer < Test::Unit::TestCase
      def setup
        @invoicer = Invoicer
      end
      def test_group_by_partner
        trans1 = FlexMock.new
        trans1.mock_handle(:partner) { 'Group1' }
        trans1.mock_handle(:model) { 'Model1' }
        trans2 = FlexMock.new
        trans2.mock_handle(:partner) { 'Group2' }
        trans2.mock_handle(:model) { 'Model2' }
        trans3 = FlexMock.new
        trans3.mock_handle(:partner) { 'Group1' }
        trans3.mock_handle(:model) { 'Model3' }
        transactions = [trans1, trans2, trans3]
        expected = {
          'Group1'  => ['Model1', 'Model3'],
          'Group2'  => ['Model2']
        }
        assert_equal(expected, @invoicer.group_by_partner(transactions))
      end
    end
  end
end
