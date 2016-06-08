#!/usr/bin/env ruby
# TestParty -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/model/party'
require "minitest/autorun"
require 'flexmock/minitest'

module XmlConv
	module Model
		class TestParty < Minitest::Test
			def setup
				@party = Party.new
			end
			def test_attr_accessors
				assert_respond_to(@party, :role)
				assert_respond_to(@party, :role=)
				assert_respond_to(@party, :name)
				assert_respond_to(@party, :name=)
				assert_respond_to(@party, :employee)
				assert_respond_to(@party, :employee=)
				assert_respond_to(@party, :address)
				assert_respond_to(@party, :address=)
			end
			def test_attr_readers
				assert_respond_to(@party, :ids)
				assert_respond_to(@party, :acc_id)
			end
			def test_add_id
				assert_equal({}, @party.ids)
				@party.add_id('ACC', 'id_string')
				assert_equal({'ACC' => 'id_string'}, @party.ids)
				assert_equal('id_string', @party.acc_id)
			end
			def test_add_party
				employee = flexmock('Employee')
				employee.should_receive(:role).at_least.once.and_return('Employee')
				@party.add_party(employee)
				assert_equal(employee, @party.employee)
				assert_equal([employee], @party.parties)
				ship_to = flexmock('ShipTo')
				ship_to.should_receive(:role).at_least.once.and_return('ShipTo')
				@party.add_party(ship_to)
				assert_equal(employee, @party.employee)
				assert_equal(ship_to, @party.ship_to)
				assert_equal([employee, ship_to], @party.parties)
				bill_to = flexmock('BillTo')
				bill_to.should_receive(:role).at_least.once.and_return('BillTo')
				@party.add_party(bill_to)
				assert_equal(employee, @party.employee)
				assert_equal(bill_to, @party.bill_to)
				assert_equal([employee, ship_to, bill_to], @party.parties)
			end
			def test_party_id
				assert_nil(@party.party_id)
				@party.add_id('ACC', 'id_string')
				assert_equal('id_string', @party.party_id)
			end
			def test_name
				assert_nil(@party.name)
				@party.name = 'a_string'
				assert_equal('a_string', @party.name)
				name = flexmock('Name')
				@party.name = name
				assert_equal(name, @party.name)
			end
			def test_employee
				employee = flexmock('Employee')
				employee.should_receive(:role).at_least.once.and_return('Employee')
				@party.add_party(employee)
				assert_equal(employee, @party.employee)
				assert_equal([employee], @party.parties)
				ship_to = flexmock('ShipTo')
				ship_to.should_receive(:role).at_least.once.and_return('ShipTo')
				@party.add_party(ship_to)
				assert_equal(employee, @party.employee)
				assert_equal(ship_to, @party.ship_to)
				assert_equal([employee, ship_to], @party.parties)
				bill_to = flexmock('BillTo')
				bill_to.should_receive(:role).at_least.once.and_return('BillTo')
				@party.add_party(bill_to)
				assert_equal(employee, @party.employee)
				assert_equal(bill_to, @party.bill_to)
				assert_equal([employee, ship_to, bill_to], @party.parties)
			end
		end
	end
end
