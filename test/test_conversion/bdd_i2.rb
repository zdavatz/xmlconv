#!/usr/bin/env ruby
# TestBddEdi -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/bdd_i2'
require 'mock'

module XmlConv
	module Conversion
		class TestBddI2 < Test::Unit::TestCase
			def test_bdd2i2
				bdd = Mock.new
				bdd.__next(:deliveries) { [] }
				i2 = BddI2.bdd2i2(bdd)
				assert_instance_of(I2::Document, i2)
				header = i2.header
				assert_instance_of(I2::Header, header)
				# test filename... -> ???
				assert_equal("EPIN_PLICA", header.recipient_id)
				expected = Time.now.strftime("EPIN_PLICA_%Y%m%d%H%M%S.dat")
				assert_equal(expected, header.filename)
			end
			def test__doc_add_delivery
				doc = I2::Document.new
				delivery = Mock.new
				delivery.__next(:bsr_id) { 'BSR-ID' }
				delivery.__next(:customer_id) { 'Customer-Delivery-Id' }
				delivery.__next(:customer) {}
				delivery.__next(:items) { [] }
				BddI2._doc_add_delivery(doc, delivery)
				order = doc.orders.first
				assert_equal('BSR-ID', order.sender_id)
				assert_equal('Customer-Delivery-Id', order.delivery_id)
			end
			def test__order_add_customer
				order = Mock.new('Order')
				customer = Mock.new('Customer')
				bill_to = Mock.new('BillTo')
				ship_to = Mock.new('ShipTo')
				bdd_addr = Mock.new('Address')
				customer.__next(:bill_to) { bill_to }
				customer.__next(:ship_to) { ship_to }
				bill_to.__next(:acc_id) { 'id_string' }
				ship_to.__next(:address) { bdd_addr }
				ship_to.__next(:name) { 'Name' }
				bdd_addr.__next(:size) { 0 }
				bdd_addr.__next(:lines) { [] }
				bdd_addr.__next(:city) { 'City' } 
				bdd_addr.__next(:zip_code) { 'ZipCode' } 
				order.__next(:add_address) { |addr|
					assert_instance_of(I2::Address, addr)
					assert_equal('id_string', addr.buyer_id)
					assert_equal(:buyer, addr.code)
				}
				order.__next(:add_address) { |addr|
					assert_instance_of(I2::Address, addr)
					assert_equal('Name', addr.name1)
					assert_equal('City', addr.city)
					assert_equal('ZipCode', addr.zip_code)
				}
				BddI2._order_add_customer(order, customer)
				order.__verify
				customer.__verify
				ship_to.__verify
				bdd_addr.__verify
			end
			def test__address_add_bdd_addr__0_lines
				address = Mock.new('Address')
				bdd_addr = Mock.new('BddAddress')
				bdd_addr.__next(:size) { 0 }
				bdd_addr.__next(:lines) { [] }
				bdd_addr.__next(:city) { 'City' }
				bdd_addr.__next(:zip_code) { 'ZipCode' }
				address.__next(:city=) { |city| 
					assert_equal('City', city)
				}
				address.__next(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.__verify
				bdd_addr.__verify
			end
			def test__address_add_bdd_addr__1_line
				address = Mock.new('Address')
				bdd_addr = Mock.new('BddAddress')
				bdd_addr.__next(:size) { 1 }
				bdd_addr.__next(:lines) {
					['Line1']
				}
				bdd_addr.__next(:city) { 'City' }
				bdd_addr.__next(:zip_code) { 'ZipCode' }
				address.__next(:street1=) { |line|
					assert_equal('Line1', line)
				}
				address.__next(:city=) { |city| 
					assert_equal('City', city)
				}
				address.__next(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.__verify
				bdd_addr.__verify
			end
			def test__address_add_bdd_addr__2_lines
				address = Mock.new('Address')
				bdd_addr = Mock.new('BddAddress')
				bdd_addr.__next(:size) { 2 }
				bdd_addr.__next(:lines) {
					['Line1', 'Line2']
				}
				bdd_addr.__next(:city) { 'City' }
				bdd_addr.__next(:zip_code) { 'ZipCode' }
				address.__next(:name2=) { |line|
					assert_equal('Line1', line)
				}
				address.__next(:street1=) { |line|
					assert_equal('Line2', line)
				}
				address.__next(:city=) { |city| 
					assert_equal('City', city)
				}
				address.__next(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.__verify
				bdd_addr.__verify
			end
			def test__address_add_bdd_addr__3_lines
				address = Mock.new('Address')
				bdd_addr = Mock.new('BddAddress')
				bdd_addr.__next(:size) { 3 }
				bdd_addr.__next(:lines) {
					['Line1', 'Line2', 'Line3']
				}
				bdd_addr.__next(:city) { 'City' }
				bdd_addr.__next(:zip_code) { 'ZipCode' }
				address.__next(:name2=) { |name|
					assert_equal('Line1', name)
				}
				address.__next(:street1=) { |line|
					assert_equal('Line2', line)
				}
				address.__next(:street2=) { |line|
					assert_equal('Line3', line)
				}
				address.__next(:city=) { |city| 
					assert_equal('City', city)
				}
				address.__next(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.__verify
				bdd_addr.__verify
			end
			def test__address_add_bdd_addr__more_than_3_lines
				address = Mock.new('Address')
				bdd_addr = Mock.new('BddAddress')
				bdd_addr.__next(:size) { 9 }
				bdd_addr.__next(:lines) {
					['Line1', 'Line2', 'Line3']
				}
				bdd_addr.__next(:city) { 'City' }
				bdd_addr.__next(:zip_code) { 'ZipCode' }
				address.__next(:name2=) { |name|
					assert_equal('Line1', name)
				}
				address.__next(:street1=) { |line|
					assert_equal('Line2', line)
				}
				address.__next(:street2=) { |line|
					assert_equal('Line3', line)
				}
				address.__next(:city=) { |city| 
					assert_equal('City', city)
				}
				address.__next(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.__verify
				bdd_addr.__verify
			end
			def test__order_add_item__no_date
				order = Mock.new('Order')
				item = Mock.new('Item')
				item.__next(:line_no) { 'LineNo' }
				item.__next(:et_nummer_id) { 'EtNummerId' }
				item.__next(:qty) { 17 }
				item.__next(:delivery_date) { }
				order.__next(:add_position) { |position|
					assert_instance_of(I2::Position, position)
					assert_equal('LineNo', position.number)
					assert_equal('EtNummerId', position.article_ean)
					assert_equal(17, position.qty)
					assert_nil(position.delivery_date)
				}
				BddI2._order_add_item(order, item)
				order.__verify
				item.__verify
			end
			def test__order_add_item
				order = Mock.new('Order')
				item = Mock.new('Item')
				a_date = Date.new(1975,8,21)
				item.__next(:line_no) { 'LineNo' }
				item.__next(:et_nummer_id) { 'EtNummerId' }
				item.__next(:qty) { 17 }
				item.__next(:delivery_date) { a_date }
				order.__next(:add_position) { |position|
					assert_instance_of(I2::Position, position)
					assert_equal('LineNo', position.number)
					assert_equal('EtNummerId', position.article_ean)
					assert_equal(17, position.qty)
					i2date = position.delivery_date
					assert_instance_of(I2::Date, i2date)
					assert_equal(a_date, i2date)
					assert_equal(:delivery, i2date.code)
				}
				BddI2._order_add_item(order, item)
				order.__verify
				item.__verify
			end
		end
	end
end
