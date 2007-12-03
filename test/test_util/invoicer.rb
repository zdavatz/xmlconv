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
        trans1.should_receive(:partner)\
          .times(1).and_return { 'Group1' }
        trans1.should_receive(:model)\
          .times(1).and_return { 'Model1' }
        trans2 = FlexMock.new
        trans2.should_receive(:partner)\
          .times(1).and_return { 'Group2' }
        trans2.should_receive(:model)\
          .times(1).and_return { 'Model2' }
        trans3 = FlexMock.new
        trans3.should_receive(:partner)\
          .times(1).and_return { 'Group1' }
        trans3.should_receive(:model)\
          .times(1).and_return { 'Model3' }
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
