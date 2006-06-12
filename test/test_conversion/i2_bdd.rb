#!/usr/bin/env ruby
# TestI2Bdd -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/i2_bdd'
require 'mock'

module XmlConv
	module Conversion
		class TestI2Bdd < Test::Unit::TestCase
			class IsAMock < Mock
				def is_a?(klass)
					true
				end
			end
			def setup
				@src = <<-EOS
"00" "Sender Identification" "Recipient Identification" 
	"20040628" "1159" "CONFIRM" "1"
"01" "456" "Receipt-Number" "20040627" "Order Number" "Commission"
	"OC" "Employee" 
"02" "BY" "Name1" "Name2" "Street" "City" "AddressCode" "Country"
"02" "SE" "Name1" "Name2" "Street" "City" "AddressCode" "Country"
"02" "DP" "Name1" "Name2" "Street" "City" "AddressCode" "Country"
"05" "A single Header-Text"
"05" "Another single Header-Text"
"10" "LineNo" "EAN13" "IdBuyer" "Quantity" 
	"DeliveryDate" "PriceNetto" "PriceNetto * Quantity" "Discount" 
	"Discount * Quantity" "Special Discount" "Special Discount * Quantity"
	"PriceBrutto" "PriceBrutto * Quantity" 
"10" "LineNo" "EAN13" "IdBuyer" "Quantity" 
	"DeliveryDate" "PriceNetto" "PriceNetto * Quantity" "Discount" 
	"Discount * Quantity" "Special Discount" "Special Discount * Quantity"
	"PriceBrutto" "PriceBrutto * Quantity"
"10" "LineNo" "EAN13" "IdBuyer" "Quantity" 
	"DeliveryDate" "PriceNetto" "PriceNetto * Quantity" "Discount" 
	"Discount * Quantity" "Special Discount" "Special Discount * Quantity"
	"PriceBrutto" "PriceBrutto * Quantity"
"90" "Price Netto" "VAT %" "VAT Amount" "Price Brutto" "Agreement"
				EOS
			end
			def ast_mock(name, value)
				ast = Mock.new(name)
				ast.__next(:attributes) { {'value' => value} }
				ast.__next(:value) { value }
				ast
			end
			def test_convert
				ast = Mock.new('AbstractSyntaxTree')
				records = Mock.new('ArrayNode')
				record = Mock.new('Record')
				text = Mock.new('Text')
				text.__next(:attributes) { {} }
				record.__next(:name) { 'HeaderText' }
				record.__next(:text) { text }
				records.__next(:each_node) { |block| block.call(record) }
				ast.__next(:records) { records }
				bdd = I2Bdd.convert(ast)
				assert_instance_of(Model::Bdd, bdd)
				ast.__verify
				records.__verify
				record.__verify
				text.__verify
			end
			def test__bdd_add_header__confirm
				bdd = Mock.new('Bdd')
				ast = Mock.new('AST')
				date = Mock.new('Date')
				time = Mock.new('Time')
				mtype = Mock.new('MType')
				recipient = Mock.new('Recipient')
				recipient.__next(:attributes) { 'value' }
				recipient.__next(:value) { 'RecipientName' }
				mtype.__next(:attributes) { 'value' }
				mtype.__next(:value) { 'CONFIRM' }
				time.__next(:attributes) { 'value' }
				time.__next(:value) { '1754' }
				date.__next(:attributes) { 'value' }
				date.__next(:value) { '20040628' }
				ast.__next(:date) { date }
				ast.__next(:time) { time }
				ast.__next(:mtype) { mtype }
				ast.__next(:recipient) { recipient }
				bdd.__next(:bsr=) { |bsr| 
					assert_instance_of(Model::Bsr, bsr)
					assert_equal(Time.local(2004, 6, 28, 17, 54), bsr.timestamp)
					assert_equal('Return', bsr.verb)
					assert_equal('Status', bsr.noun)
					assert_equal(1, bsr.parties.size)
					party = bsr.parties.first
					assert_instance_of(Model::Party, party)
					assert_equal('Customer', party.role)
					name = party.name
					assert_instance_of(Model::Name, name)
					assert_equal('RecipientName', name.to_s)
				}
				I2Bdd._bdd_add_header(bdd, ast)
				bdd.__verify
				ast.__verify
				date.__verify
				time.__verify
				mtype.__verify
				recipient.__verify
			end
			def test__bdd_add_header__invoice
				bdd = Mock.new('Bdd')
				ast = Mock.new('AST')
				date = Mock.new('Date')
				time = Mock.new('Time')
				mtype = Mock.new('MType')
				recipient = Mock.new('Recipient')
				recipient.__next(:attributes) { 'value' }
				recipient.__next(:value) { 'RecipientName' }
				mtype.__next(:attributes) { 'value' }
				mtype.__next(:value) { 'INVOIC' }
				time.__next(:attributes) { 'value' }
				time.__next(:value) { '1754' }
				date.__next(:attributes) { 'value' }
				date.__next(:value) { '20040628' }
				ast.__next(:date) { date }
				ast.__next(:time) { time }
				ast.__next(:mtype) { mtype }
				ast.__next(:recipient) { recipient }
				bdd.__next(:bsr=) { |bsr| 
					assert_instance_of(Model::Bsr, bsr)
					assert_equal(Time.local(2004, 6, 28, 17, 54), bsr.timestamp)
					assert_equal('Return', bsr.verb)
					assert_equal('Invoice', bsr.noun)
					assert_equal(1, bsr.parties.size)
					party = bsr.parties.first
					assert_instance_of(Model::Party, party)
					assert_equal('Customer', party.role)
					name = party.name
					assert_instance_of(Model::Name, name)
					assert_equal('RecipientName', name.to_s)
				}
				I2Bdd._bdd_add_header(bdd, ast)
				bdd.__verify
				ast.__verify
				date.__verify
				time.__verify
				mtype.__verify
			end
			def test__bdd_add_header_text
				ast = Mock.new('AST')
				bdd = Mock.new('BDD')
				bsr = Mock.new('BSR')
				invoice = Mock.new('Invoice')
				text = ast_mock('Text', 'Free Text')
				invoice.__next(:free_text) {}
				invoice.__next(:add_free_text) { |type, free_text| 
					assert_nil(type)
					assert_equal('Free Text', free_text)
				}
				bsr.__next(:noun) { 'Invoice' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:invoices) { [ invoice ] }
				ast.__next(:text) { text }
				I2Bdd._bdd_add_header_text(bdd, ast)
				ast.__verify
				bdd.__verify
				bsr.__verify
				invoice.__verify
				text.__verify
			end
			def test__bdd_add_commission__invalid
				ast = Mock.new('AST')
				bdd = Mock.new('Bdd')
				bdd.__next(:bsr) { }
				assert_raises(RuntimeError) { 
					I2Bdd._bdd_add_commission(bdd, ast)
				}
				bsr = Mock.new('Bsr')
				bsr.__next(:noun) { }
				bdd.__next(:bsr) { bsr }
				assert_raises(RuntimeError) { 
					I2Bdd._bdd_add_commission(bdd, ast)
				}
				ast.__verify
				bdd.__verify
				bsr.__verify
			end
			def test__bdd_add_delivery
				bdd = Mock.new('Bdd')
				ast = Mock.new('AST')
				reference = ast_mock('Reference', 'Reference-Id')
				commission = ast_mock('Commission', 'Commission-Id')
				rdate = ast_mock('RDate', '20040629')
				empl = ast_mock('Employee', 'Employee Name')
				ast.__next(:reference) { reference }
				ast.__next(:rdate) { rdate }
				ast.__next(:commission) { commission }
				ast.__next(:employee) { empl }
				bdd.__next(:add_delivery) { |delivery|
					assert_instance_of(Model::Delivery, delivery)
					assert_equal('Confirmed', delivery.status)
					assert_equal(2, delivery.ids.size)
					assert_equal(Date.new(2004, 6, 29), delivery.status_date)
					assert_equal('Commission-Id', delivery.ids['Customer'])
					assert_equal(2, delivery.parties.size)
					seller = delivery.parties.first
					assert_equal('Seller', seller.role)
					assert_instance_of(Model::Party, seller)
					customer = delivery.parties.last
					assert_equal('Customer', customer.role)
					assert_instance_of(Model::Party, customer)
					assert_equal(1, customer.parties.size)
					employee = customer.parties.first
					assert_instance_of(Model::Party, employee)
					assert_equal('Employee', employee.role)
					name = employee.name
					assert_instance_of(Model::Name, name)
					assert_equal('Employee Name', name.text)
				}
				I2Bdd._bdd_add_delivery(bdd, ast)
				bdd.__verify
				ast.__verify
				reference.__verify
				commission.__verify
				rdate.__verify
				empl.__verify
			end
			def test__bdd_add_invoice
				bdd = Mock.new('Bdd')
				ast = Mock.new('AST')
				reference = ast_mock('Reference', 'Reference-Id')
				receipt = ast_mock('Invoice', 'Receipt-Number')
				commission = ast_mock('Commission', 'Commission-Id')
				rdate = ast_mock('RDate', '20040629')
				empl = ast_mock('Employee', 'Employee Name')
				ast.__next(:receipt) { receipt }
				ast.__next(:reference) { reference }
				ast.__next(:rdate) { rdate }
				ast.__next(:commission) { commission }
				ast.__next(:employee) { empl }
				bdd.__next(:add_invoice) { |invoice|
					assert_instance_of(Model::Invoice, invoice)
					assert_equal(['ACC', 'Reference-Id'], invoice.delivery_id)
					assert_equal(['Invoice', 'Receipt-Number'], invoice.invoice_id)
					assert_equal('Invoiced', invoice.status)
					assert_equal(1, invoice.ids.size)
					assert_equal(Date.new(2004, 6, 29), invoice.status_date)
					assert_equal('Commission-Id', invoice.ids['Customer'])
					assert_equal(2, invoice.parties.size)
					seller = invoice.parties.first
					assert_equal('Seller', seller.role)
					assert_instance_of(Model::Party, seller)
					customer = invoice.parties.last
					assert_equal('Customer', customer.role)
					assert_instance_of(Model::Party, customer)
					assert_equal(1, customer.parties.size)
					employee = customer.parties.first
					assert_instance_of(Model::Party, employee)
					assert_equal('Employee', employee.role)
					name = employee.name
					assert_instance_of(Model::Name, name)
					assert_equal('Employee Name', name.text)
				}
				I2Bdd._bdd_add_invoice(bdd, ast)
				bdd.__verify
				ast.__verify
				reference.__verify
				commission.__verify
				rdate.__verify
				empl.__verify
			end
			def test__bdd_transaction_type
				bdd = Mock.new('Bdd')
				bdd.__next(:bsr) { }
				assert_raises(RuntimeError) { I2Bdd._bdd_transaction_type(bdd) }
				bsr = Mock.new('Bsr')
				bsr.__next(:noun) { }
				bdd.__next(:bsr) { bsr }
				assert_raises(RuntimeError) { I2Bdd._bdd_transaction_type(bdd) }
				bsr.__next(:noun) { 'Invoice' }
				bdd.__next(:bsr) { bsr }
				assert_equal('Invoice', I2Bdd._bdd_transaction_type(bdd))
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				assert_equal('Delivery', I2Bdd._bdd_transaction_type(bdd))
				bdd.__verify
				bsr.__verify
			end
			def test__bdd_add_address__se
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				delivery = Mock.new('Delivery')
				seller = Mock.new('Seller')
				address = Mock.new('Address')
				atype = ast_mock('AType', 'SE')
				name1 = ast_mock('Name1', 'Name 1')
				name2 = ast_mock('Name2', 'Name 2')
				street = ast_mock('Street', 'Street')
				city = ast_mock('City', 'City')
				code = ast_mock('Code', 'Code')
				country = ast_mock('Country', 'Country')
				address.__next(:atype) { atype }
				address.__next(:name1) { name1 }
				address.__next(:name2) { name2 }
				address.__next(:street) { street }
				address.__next(:city) { city }
				address.__next(:code) { code }
				address.__next(:country) { country }
				seller.__next(:address=) { |bdd_addr|
					assert_instance_of(Model::Address, bdd_addr)
					assert_equal(3, bdd_addr.lines.size)
					assert_equal('Name 1', bdd_addr.lines.at(0))
					assert_equal('Name 2', bdd_addr.lines.at(1))
					assert_equal('Street', bdd_addr.lines.at(2))
					assert_equal('City', bdd_addr.city)
					assert_equal('Code', bdd_addr.zip_code)
					assert_equal('Country', bdd_addr.country)
				}
				delivery.__next(:seller) { seller }
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				I2Bdd._bdd_add_address(bdd, address)
				bdd.__verify
				bsr.__verify
				delivery.__verify
				address.__verify
				atype.__verify
				name1.__verify
				name2.__verify
				street.__verify
				city.__verify
				code.__verify
				country.__verify
			end
			def test__bdd_add_address__cu
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				delivery = Mock.new('Delivery')
				customer = Mock.new('Customer')
				address = Mock.new('Address')
				atype = ast_mock('AType', 'CU')
				name1 = ast_mock('Name1', 'Name 1')
				name2 = ast_mock('Name2', 'Name 2')
				street = ast_mock('Street', 'Street')
				city = ast_mock('City', 'City')
				code = ast_mock('Code', 'Code')
				country = ast_mock('Country', 'Country')
				address.__next(:atype) { atype }
				address.__next(:name1) { name1 }
				address.__next(:name2) { name2 }
				address.__next(:street) { street }
				address.__next(:city) { city }
				address.__next(:code) { code }
				address.__next(:country) { country }
				customer.__next(:address=) { |bdd_addr|
					assert_instance_of(Model::Address, bdd_addr)
					assert_equal(3, bdd_addr.lines.size)
					assert_equal('Name 1', bdd_addr.lines.at(0))
					assert_equal('Name 2', bdd_addr.lines.at(1))
					assert_equal('Street', bdd_addr.lines.at(2))
					assert_equal('City', bdd_addr.city)
					assert_equal('Code', bdd_addr.zip_code)
					assert_equal('Country', bdd_addr.country)
				}
				delivery.__next(:customer) { customer }
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				I2Bdd._bdd_add_address(bdd, address)
				bdd.__verify
				bsr.__verify
				delivery.__verify
				address.__verify
				atype.__verify
				name1.__verify
				name2.__verify
				street.__verify
				city.__verify
				code.__verify
				country.__verify
			end
			def test__bdd_add_address__dp
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				delivery = Mock.new('Delivery')
				customer = Mock.new('Customer')
				address = Mock.new('Address')
				atype = ast_mock('AType', 'DP')
				name1 = ast_mock('Name1', 'Name 1')
				name2 = ast_mock('Name2', 'Name 2')
				street = ast_mock('Street', 'Street')
				city = ast_mock('City', 'City')
				code = ast_mock('Code', 'Code')
				country = ast_mock('Country', 'Country')
				address.__next(:atype) { atype }
				address.__next(:name1) { name1 }
				address.__next(:name2) { name2 }
				address.__next(:street) { street }
				address.__next(:city) { city }
				address.__next(:code) { code }
				address.__next(:country) { country }
				customer.__next(:add_party) { |bdd_party|
					assert_equal('ShipTo', bdd_party.role)
					bdd_addr = bdd_party.address
					assert_instance_of(Model::Address, bdd_addr)
					assert_equal(3, bdd_addr.lines.size)
					assert_equal('Name 1', bdd_addr.lines.at(0))
					assert_equal('Name 2', bdd_addr.lines.at(1))
					assert_equal('Street', bdd_addr.lines.at(2))
					assert_equal('City', bdd_addr.city)
					assert_equal('Code', bdd_addr.zip_code)
					assert_equal('Country', bdd_addr.country)
				}
				delivery.__next(:customer) { customer }
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				I2Bdd._bdd_add_address(bdd, address)
				bdd.__verify
				bsr.__verify
				delivery.__verify
				address.__verify
				atype.__verify
				name1.__verify
				name2.__verify
				street.__verify
				city.__verify
				code.__verify
				country.__verify
			end
			def test__bdd_add_address__by
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				delivery = Mock.new('Delivery')
				customer = Mock.new('Customer')
				address = Mock.new('Address')
				atype = ast_mock('AType', 'BY')
				name1 = ast_mock('Name1', 'Name 1')
				name2 = ast_mock('Name2', 'Name 2')
				street = ast_mock('Street', 'Street')
				city = ast_mock('City', 'City')
				code = ast_mock('Code', 'Code')
				country = ast_mock('Country', 'Country')
				address.__next(:atype) { atype }
				address.__next(:name1) { name1 }
				address.__next(:name2) { name2 }
				address.__next(:street) { street }
				address.__next(:city) { city }
				address.__next(:code) { code }
				address.__next(:country) { country }
				customer.__next(:add_party) { |bdd_party|
					assert_equal('BillTo', bdd_party.role)
					bdd_addr = bdd_party.address
					assert_instance_of(Model::Address, bdd_addr)
					assert_equal(3, bdd_addr.lines.size)
					assert_equal('Name 1', bdd_addr.lines.at(0))
					assert_equal('Name 2', bdd_addr.lines.at(1))
					assert_equal('Street', bdd_addr.lines.at(2))
					assert_equal('City', bdd_addr.city)
					assert_equal('Code', bdd_addr.zip_code)
					assert_equal('Country', bdd_addr.country)
				}
				delivery.__next(:customer) { customer }
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				I2Bdd._bdd_add_address(bdd, address)
				bdd.__verify
				bsr.__verify
				delivery.__verify
				address.__verify
				atype.__verify
				name1.__verify
				name2.__verify
				street.__verify
				city.__verify
				code.__verify
				country.__verify
			end
			def test__bdd_add_address__ep
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				delivery = Mock.new('Delivery')
				customer = Mock.new('Customer')
				address = Mock.new('Address')
				employee = Mock.new('Employee')
				atype = ast_mock('AType', 'EP')
				name1 = ast_mock('Name1', 'Name 1')
				name2 = ast_mock('Name2', 'Name 2')
				street = ast_mock('Street', 'Street')
				city = ast_mock('City', 'City')
				code = ast_mock('Code', 'Code')
				country = ast_mock('Country', 'Country')
				address.__next(:atype) { atype }
				address.__next(:name1) { name1 }
				address.__next(:name2) { name2 }
				address.__next(:street) { street }
				address.__next(:city) { city }
				address.__next(:code) { code }
				address.__next(:country) { country }
				employee.__next(:address=) { |bdd_addr|
					assert_instance_of(Model::Address, bdd_addr)
					assert_equal(3, bdd_addr.lines.size)
					assert_equal('Name 1', bdd_addr.lines.at(0))
					assert_equal('Name 2', bdd_addr.lines.at(1))
					assert_equal('Street', bdd_addr.lines.at(2))
					assert_equal('City', bdd_addr.city)
					assert_equal('Code', bdd_addr.zip_code)
					assert_equal('Country', bdd_addr.country)
				}
				customer.__next(:employee) { employee }
				delivery.__next(:customer) { customer }
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				I2Bdd._bdd_add_address(bdd, address)
				bdd.__verify
				bsr.__verify
				delivery.__verify
				address.__verify
				atype.__verify
				name1.__verify
				name2.__verify
				street.__verify
				city.__verify
				code.__verify
				country.__verify
			end
			def test__bdd_add_position__delivery
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				delivery = IsAMock.new('Delivery')
				position = Mock.new('Position')
				lineno = ast_mock('LineNo', '10')
				eancode = ast_mock('EanCode', '1234567890987')
				#sellercode = ast_mock('SellerCode', 'Seller-Code')
				buyercode = ast_mock('BuyerCode', 'Buyer-Code')
				#description1 = ast_mock('Description1', 'Description 1')
				#description2 = ast_mock('Description2', 'Description 2')
				quantity = ast_mock('Quantity', '100')
				price1 = ast_mock('Price1', '123.45')
				price2 = ast_mock('Price2', '246.90')
				price3 = ast_mock('Price3', '3')
				price4 = ast_mock('Price4', '6')
				price5 = ast_mock('Price5', '1')
				price6 = ast_mock('Price6', '2')
				price7 = ast_mock('Price7', '119.45')
				price8 = ast_mock('Price8', '238.90')
				ddate = ast_mock('DDate', '20040629')
				position.__next(:lineno) { lineno }
				position.__next(:eancode) { eancode }
				#position.__next(:sellercode) { sellercode }
				position.__next(:buyercode) { buyercode }
				#position.__next(:description1) { description1 }
				#position.__next(:description2) { description2 }
				position.__next(:qty) { quantity }
				position.__next(:pricenettopce) { price1 }
				position.__next(:pricenetto) { price2 }
				position.__next(:discountpce) { price3 }
				position.__next(:discount) { price4 }
				position.__next(:extradiscountpce) { price5 }
				position.__next(:extradiscount) { price6 }
				position.__next(:pricebruttopce) { price7 }
				position.__next(:pricebrutto) { price8 }
				position.__next(:ddate) { ddate }
				delivery.__next(:is_a?) { |klass| 
					assert_equal(Model::Invoice, klass)
					false
				}
				delivery.__next(:add_item) { |item|
					assert_instance_of(Model::DeliveryItem, item)
					#assert_equal('10', item.line_no)
					assert_equal(2, item.ids.size)
					assert_equal('1234567890987', item.ids['EAN-Nummer'])
					#assert_equal('Seller-Code', item.ids['Lieferantenartikel'])
					assert_equal('Buyer-Code', item.ids['ET-Nummer'])
					assert_nil(item.free_text)
					#free_text = item.free_text
					#assert_instance_of(Model::FreeText, free_text)
					#assert_equal('Bezeichnung', free_text.type)
					#assert_equal("Description 1\nDescription 2", free_text)
					assert_equal('100', item.qty)
					assert_equal(8, item.prices.size)
					assert_equal('NettoPreis', item.prices.at(0).purpose)
					assert_equal('123.45', item.prices.at(0).amount)
					assert_equal('NettoPreisME', item.prices.at(1).purpose)
					assert_equal('246.90', item.prices.at(1).amount)
					assert_equal('Grundrabatt', item.prices.at(2).purpose)
					assert_equal('3.00', item.prices.at(2).amount)
					assert_equal('GrundrabattME', item.prices.at(3).purpose)
					assert_equal('6.00', item.prices.at(3).amount)
					assert_equal('Sonderrabatt', item.prices.at(4).purpose)
					assert_equal('1.00', item.prices.at(4).amount)
					assert_equal('SonderrabattME', item.prices.at(5).purpose)
					assert_equal('2.00', item.prices.at(5).amount)
					assert_equal('BruttoPreis', item.prices.at(6).purpose)
					assert_equal('119.45', item.prices.at(6).amount)
					assert_equal('BruttoPreisME', item.prices.at(7).purpose)
					assert_equal('238.90', item.prices.at(7).amount)
					assert_equal(Date.new(2004, 6, 29), item.delivery_date)
				}
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				I2Bdd._bdd_add_position(bdd, position)
				bdd.__verify
				bsr.__verify
				delivery.__verify
				position.__verify
				lineno.__verify
				eancode.__verify
				#sellercode.__verify
				buyercode.__verify
				#description1.__verify
				#description2.__verify
				price1.__verify
				price2.__verify
				price3.__verify
				price4.__verify
				price5.__verify
				price6.__verify
				price7.__verify
				price8.__verify
				ddate.__verify
			end
			def test__bdd_add_position__invoice
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				invoice = IsAMock.new('Invoice')
				position = Mock.new('Position')
				lineno = ast_mock('LineNo', '10')
				eancode = ast_mock('EanCode', '1234567890987')
				#sellercode = ast_mock('SellerCode', 'Seller-Code')
				buyercode = ast_mock('BuyerCode', 'Buyer-Code')
				#description1 = ast_mock('Description1', 'Description 1')
				#description2 = ast_mock('Description2', 'Description 2')
				quantity = ast_mock('Quantity', '100')
				price1 = ast_mock('Price1', '123.45')
				price2 = ast_mock('Price2', '246.90')
				price3 = ast_mock('Price3', '3')
				price4 = ast_mock('Price4', '6')
				price5 = ast_mock('Price5', '1')
				price6 = ast_mock('Price6', '2')
				price7 = ast_mock('Price7', '119.45')
				price8 = ast_mock('Price8', '238.90')
				origin = ast_mock('Origin', 'CH')
				customs = ast_mock('Customs', 'Customs-Number')
				position.__next(:lineno) { lineno }
				position.__next(:eancode) { eancode }
				#position.__next(:sellercode) { sellercode }
				position.__next(:buyercode) { buyercode }
				#position.__next(:description1) { description1 }
				#position.__next(:description2) { description2 }
				position.__next(:qty) { quantity }
				position.__next(:pricenettopce) { price1 }
				position.__next(:pricenetto) { price2 }
				position.__next(:discountpce) { price3 }
				position.__next(:discount) { price4 }
				position.__next(:extradiscountpce) { price5 }
				position.__next(:extradiscount) { price6 }
				position.__next(:pricebruttopce) { price7 }
				position.__next(:pricebrutto) { price8 }
				position.__next(:origin) { origin }
				position.__next(:customs) { customs }
				invoice.__next(:is_a?) { |klass| 
					assert_equal(Model::Invoice, klass)
					true
				}
				invoice.__next(:add_item) { |item|
					assert_instance_of(Model::InvoiceItem, item)
					#assert_equal('10', item.line_no)
					assert_equal(2, item.ids.size)
					assert_equal('1234567890987', item.ids['EAN-Nummer'])
					#assert_equal('Seller-Code', item.ids['Lieferantenartikel'])
					assert_equal('Buyer-Code', item.ids['ET-Nummer'])
					assert_nil(item.free_text)
					#free_text = item.free_text
					#assert_instance_of(Model::FreeText, free_text)
					#assert_equal('Bezeichnung', free_text.type)
					#assert_equal("Description 1\nDescription 2", free_text)
					assert_equal('100', item.qty)
					assert_equal(8, item.prices.size)
					assert_equal('NettoPreis', item.prices.at(0).purpose)
					assert_equal('123.45', item.prices.at(0).amount)
					assert_equal('NettoPreisME', item.prices.at(1).purpose)
					assert_equal('246.90', item.prices.at(1).amount)
					assert_equal('Grundrabatt', item.prices.at(2).purpose)
					assert_equal('3.00', item.prices.at(2).amount)
					assert_equal('GrundrabattME', item.prices.at(3).purpose)
					assert_equal('6.00', item.prices.at(3).amount)
					assert_equal('Sonderrabatt', item.prices.at(4).purpose)
					assert_equal('1.00', item.prices.at(4).amount)
					assert_equal('SonderrabattME', item.prices.at(5).purpose)
					assert_equal('2.00', item.prices.at(5).amount)
					assert_equal('BruttoPreis', item.prices.at(6).purpose)
					assert_equal('119.45', item.prices.at(6).amount)
					assert_equal('BruttoPreisME', item.prices.at(7).purpose)
					assert_equal('238.90', item.prices.at(7).amount)
					assert_equal(2, item.part_infos.size)
					origin_info = item.part_infos.first
					assert_instance_of(Model::PartInfo, origin_info)
					assert_equal('Ursprungsland', origin_info.dimension)
					assert_equal('CH', origin_info.value)
					customs_info = item.part_infos.last
					assert_instance_of(Model::PartInfo, customs_info)
					assert_equal('Zolltarifnr.', customs_info.dimension)
					assert_equal('Customs-Number', customs_info.value)
				}
				bsr.__next(:noun) { 'Invoice' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:invoices) { [invoice] }
				I2Bdd._bdd_add_position(bdd, position)
				bdd.__verify
				bsr.__verify
				invoice.__verify
				position.__verify
				lineno.__verify
				eancode.__verify
				#sellercode.__verify
				buyercode.__verify
				#description1.__verify
				#description2.__verify
				price1.__verify
				price2.__verify
				price3.__verify
				price4.__verify
				price5.__verify
				price6.__verify
				price7.__verify
				price8.__verify
			end
			def test__bdd_add_footer
				ast = Mock.new('AST')
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				delivery = Mock.new('Delivery')
				pricenetto = ast_mock('PriceNetto', '100')
				vatpercent = ast_mock('VatPercent', '7.6')
				vatamount = ast_mock('VatAmount', '7.6')
				pricebrutto = ast_mock('PriceBrutto', '107.6')
				agreement = ast_mock('Agreement', 'Agreement-Text')
				delivery.__next(:add_price) { |price|
					assert_instance_of(Model::Price, price)
					assert_equal('SummePositionen', price.purpose)
					assert_equal('100.00', price.amount)
				}
				delivery.__next(:add_price) { |price|
					assert_instance_of(Model::Price, price)
					assert_equal('MehrwertsteuerPct', price.purpose)
					assert_equal('7.60', price.amount)
				}
				delivery.__next(:add_price) { |price|
					assert_instance_of(Model::Price, price)
					assert_equal('Mehrwertsteuer', price.purpose)
					assert_equal('7.60', price.amount)
				}
				delivery.__next(:add_price) { |price|
					assert_instance_of(Model::Price, price)
					assert_equal('Endbetrag', price.purpose)
					assert_equal('107.60', price.amount)
				}
				delivery.__next(:agreement=) { |bdd_agr|
					assert_instance_of(Model::Agreement, bdd_agr)
					assert_equal('Agreement-Text', bdd_agr.terms_cond)
				}
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				ast.__next(:pricenetto) { pricenetto }
				ast.__next(:vatpercent) { vatpercent }
				ast.__next(:vatamount) { vatamount }
				ast.__next(:pricebrutto) { pricebrutto }
				ast.__next(:agreement) { agreement }
				I2Bdd._bdd_add_footer(bdd, ast)
				ast.__verify
				bdd.__verify
				bsr.__verify
				delivery.__verify
				pricenetto.__verify
				vatpercent.__verify
				vatamount.__verify
				pricebrutto.__verify
			end
			def test__select_bdd_transaction
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				bdd.__next(:bsr) { bsr }
				bsr.__next(:noun) { 'Delivery' }
				bdd.__next(:deliveries) { ['Delivery 1', 'Delivery 2'] }
				assert_equal('Delivery 2', I2Bdd._select_bdd_transaction(bdd))
				bdd.__next(:bsr) { bsr }
				bsr.__next(:noun) { 'Invoice' }
				bdd.__next(:invoices) { ['Invoice 1', 'Invoice 2'] }
				assert_equal('Invoice 2', I2Bdd._select_bdd_transaction(bdd))
				bdd.__verify
				bsr.__verify
			end
			def test_parse
				ast = I2Bdd.parse(@src)
				assert_instance_of(SyntaxTree, ast)
				assert_equal(11, ast.records.size)
			end
		end
	end
end
