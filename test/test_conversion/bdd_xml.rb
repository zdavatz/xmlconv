#!/usr/bin/env ruby
# TestBddXml -- xmlconv2 -- 21.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/bdd_xml'
require 'mock'

module XmlConv
	module Conversion
		class TestBddXml < Test::Unit::TestCase
			class ToSMock < Mock
				def to_s
					true
				end
				def type
					true
				end
			end
			def test_convert
				bdd = Mock.new('Bdd')
				bsr = Mock.new('Bsr')
				bsr.__next(:parties) { [] }
				delivery = Mock.new('Delivery')
				delivery.__next(:ids) { [] }
				delivery.__next(:parties) { [] }
				delivery.__next(:items) { [] }
				delivery.__next(:prices) { [] }
				delivery.__next(:agreement) { }
				bdd.__next(:bsr) { bsr }
				bdd.__next(:deliveries) { [delivery] }
				xml_doc = BddXml.convert(bdd)
				assert_instance_of(REXML::Document, xml_doc)
				decl = "<?xml version='1.0' encoding='UTF-8'?>"
				assert_equal(decl, xml_doc.xml_decl.to_s)
				dtd = '<!DOCTYPE BDD SYSTEM "ABB BDD.dtd">'
				assert_equal(dtd, xml_doc.doctype.to_s)
				root = xml_doc.root
				assert_instance_of(REXML::Element, root)
				assert_equal('BDD', root.name)
				assert_equal(2, root.elements.size)
				xml_bsr = root.elements[1]
				assert_instance_of(REXML::Element, xml_bsr)
				assert_equal('BSR', xml_bsr.name)
				xml_delivery = root.elements[2]
				assert_instance_of(REXML::Element, xml_delivery)
				assert_equal('Delivery', xml_delivery.name)
				bdd.__verify
				bsr.__verify
				delivery.__verify
			end
			def test__xml_add_bdd_bsr
				xml_bdd = REXML::Element.new('BDD')
				party = Mock.new('Party')
				bsr = Mock.new('Bsr')
				name = ToSMock.new('Name')
				name.__next(:text) { 'NameText' }
				name.__next(:to_s) { 'NameString' }
				bsr.__next(:parties) { [party] }
				party.__next(:role) { 'Customer' }
				party.__next(:ids) { {'ACC'	=>	'ACC-Id'} }
				party.__next(:name) { name }
				party.__next(:address) { }
				party.__next(:parties) { [] }
				BddXml._xml_add_bdd_bsr(xml_bdd, bsr)
				xml_bsr = xml_bdd.elements['BSR']
				assert_equal(4, xml_bsr.elements.size)
				timestamp = xml_bsr.elements[1]
				assert_equal('Timestamp', timestamp.name)
				assert_equal(1, timestamp.attributes.size)
				offset = Time.now.gmtoff / 3600
				offstr = sprintf("%+i", offset)
				timestr = Time.now.strftime('%Y%m%d%H%M%S')
				assert_equal(offstr, timestamp.attributes['Zone'])
				assert_equal(timestr, timestamp.text)
				verb = xml_bsr.elements[2]
				assert_equal('Verb', verb.name)
				assert_equal('Return', verb.text)
				noun = xml_bsr.elements[3]
				assert_equal('Noun', noun.name)
				assert_equal('Status', noun.text)
				xml_party = xml_bsr.elements[4]
				assert_equal('Party', xml_party.name)
				assert_equal('2', xml_party.attributes['Version'])
				assert_equal('Customer', xml_party.attributes['Role'])
				assert_equal(2, xml_party.elements.size)
				xml_id = xml_party.elements[1]
				assert_equal('PartyId', xml_id.name)
				assert_equal('ACC', xml_id.attributes['Domain'])
				assert_equal('ACC-Id', xml_id.text)
				xml_name = xml_party.elements[2]
				assert_equal('Name', xml_name.name)
				assert_equal('NameString', xml_name.text)
				bsr.__verify
				party.__verify
				name.__verify
			end
			def test__xml_add_bdd_delivery
				delivery = Mock.new('Delivery')
				party = Mock.new('Party')
				name = ToSMock.new('Name')
				agreement = Mock.new('Agreement')
				agreement.__next(:terms_cond) { 'Terms and Conditions' }
				name.__next(:text) { 'NameText' }
				name.__next(:to_s) { 'NameString' }
				party.__next(:role)	{ 'Seller' }
				party.__next(:ids) { {'ACC' => 12345} }
				party.__next(:name)	{ name }
				party.__next(:address) { }
				party.__next(:parties) { [] }
				delivery.__next(:ids) { {'ACC' => 54321} }
				delivery.__next(:parties) { [party] }
				delivery.__next(:items) { [] } 
				delivery.__next(:prices) { [] }
				delivery.__next(:agreement) { agreement }
				bdd = REXML::Element.new('BDD')
				BddXml._xml_add_bdd_delivery(bdd, delivery)
				assert_equal(1, bdd.elements.size)
				xml_delivery = bdd.elements[1]
				assert_equal(3, xml_delivery.elements.size)
				del_id = xml_delivery.elements[1]
				assert_equal('DeliveryId', del_id.name)
				assert_equal(1, del_id.attributes.size)
				assert_equal('ACC', del_id.attributes['Domain'])
				assert_equal('54321', del_id.text)
				seller = xml_delivery.elements[2]
				assert_equal('Party', seller.name)
				assert_equal(2, seller.attributes.size)
				assert_equal('2', seller.attributes['Version'])
				assert_equal('Seller', seller.attributes['Role'])
				xml_agreement = xml_delivery.elements[3]
				assert_equal('Agreement', xml_agreement.name)
				assert_equal(1, xml_agreement.elements.size)
				xml_terms = xml_agreement.elements[1]
				assert_equal('TermsCond', xml_terms.name)
				assert_equal('Terms and Conditions', xml_terms.text)
				delivery.__verify
				party.__verify
				name.__verify
				agreement.__verify
			end
			def test__xml_add_bdd_party
				party = Mock.new('Party')
				xml = Mock.new('Xml')
				address = Mock.new('Address')
				name = ToSMock.new('Name')
				subdiv = Mock.new('SubdivParty')
				employee = ToSMock.new('Employee')
				employee.__next(:text) { }
				employee.__next(:first) { }
				employee.__next(:last) { 'Employee-Name' }
				subdiv.__next(:role) { 'Employee' }
				subdiv.__next(:ids) { [] }
				subdiv.__next(:name) { employee }
				subdiv.__next(:address) { }
				subdiv.__next(:parties) { [] }
				name.__next(:text) { 'The Name' }
				name.__next(:to_s) { 'The Name' }
				address.__next(:lines) { ['Address Line'] }
				address.__next(:city)	{ 'City' }
				address.__next(:zip_code)	{ 'Zip Code' }
				party.__next(:role) { 'Customer' }
				party.__next(:ids) {
					{
						"ACC"	=>	12345,
						"EPIN"=>	54321,
					}
				}
				party.__next(:name) { name }
				party.__next(:address) { address }
				party.__next(:parties) { [subdiv] }
				xml.__next(:add_element) { |xml_party|
					assert_instance_of(REXML::Element, xml_party)
					assert_equal(2, xml_party.attributes.size)
					assert_equal('2', xml_party.attributes['Version'])
					assert_equal('Customer', xml_party.attributes['Role'])
					assert_equal(5, xml_party.elements.size)
					xml_id1 = xml_party.elements[1]
					assert_equal('PartyId', xml_id1.name)
					assert_equal('12345', xml_id1.text)
					xml_id2 = xml_party.elements[2]
					assert_equal('PartyId', xml_id2.name)
					assert_equal('54321', xml_id2.text)
					xml_name = xml_party.elements[3]
					assert_equal('Name', xml_name.name)
					assert_equal('The Name', xml_name.text)
					xml_addr = xml_party.elements[4]
					assert_equal('Address', xml_addr.name)
					assert_equal(3, xml_addr.elements.size)
					xml_employee = xml_party.elements[5]
					assert_equal('Party', xml_employee.name)
					assert_equal(1, xml_employee.elements.size)
					xml_empname = xml_employee.elements[1]
					assert_equal('Name', xml_empname.name)
				}
				BddXml._xml_add_bdd_party(xml, party)
				party.__verify
				xml.__verify
				address.__verify
				name.__verify
				subdiv.__verify
				employee.__verify
			end
			def test__xml_add_bdd_name__text
				xml = Mock.new('Xml')
				name = ToSMock.new('Name')
				name.__next(:text) { 'The Text' }
				name.__next(:to_s) { 'The String' }
				xml.__next(:add_element) { |xml_name|
					assert_instance_of(REXML::Element, xml_name)
					assert_equal('Name', xml_name.name)
					assert_equal(0, xml_name.elements.size)
					assert_equal('The String', xml_name.text)
				}
				BddXml._xml_add_bdd_name(xml, name)
				xml.__verify
				name.__verify
			end
			def test__xml_add_bdd_name__name
				xml = Mock.new('Xml')
				name = Mock.new('Name')
				name.__next(:text) { }
				name.__next(:first) { 'First Name' }
				name.__next(:last) { 'Last Name' }
				xml.__next(:add_element) { |xml_name|
					assert_instance_of(REXML::Element, xml_name)
					assert_equal('Name', xml_name.name)
					assert_equal(2, xml_name.elements.size)
					first = xml_name.elements[1]
					assert_equal('FirstName', first.name)
					assert_equal(0, first.elements.size)
					assert_equal('First Name', first.text)
					last = xml_name.elements[2]
					assert_equal('LastName', last.name)
					assert_equal(0, last.elements.size)
					assert_equal('Last Name', last.text)
				}
				BddXml._xml_add_bdd_name(xml, name)
				xml.__verify
				name.__verify
			end
			def test__xml_add_bdd_address
				address = Mock.new('Address')
				address.__next(:lines) { [ 'Line 1', 'Line 2' ] }
				address.__next(:city) { 'The City' }
				address.__next(:zip_code) { 'The ZipCode' }
				xml = Mock.new('Xml')
				xml.__next(:add_element) { |xml_addr|
					assert_instance_of(REXML::Element, xml_addr)
					assert_equal('Address', xml_addr.name)
					assert_equal(4, xml_addr.elements.size)
					line1 = xml_addr.elements[1]
					assert_equal('AddressLine', line1.name)
					assert_equal('Line 1', line1.text)
					line2 = xml_addr.elements[2]
					assert_equal('AddressLine', line2.name)
					assert_equal('Line 2', line2.text)
					city = xml_addr.elements[3]
					assert_equal('City', city.name)
					assert_equal('The City', city.text)
					zip = xml_addr.elements[4]
					assert_equal('ZipCode', zip.name)
					assert_equal(1, zip.attributes.size)
					assert_equal('CH', zip.attributes['Domain'])
					assert_equal('The ZipCode', zip.text)
				}
				BddXml._xml_add_bdd_address(xml, address)
				address.__verify
				xml.__verify
			end
			def test__xml_add_delivery_item
				xml = Mock.new('Xml')
				item = Mock.new('DeliveryItem')
				price1 = Mock.new('Price1')
				price1.__next(:purpose) { 'Purpose1' }
				price1.__next(:amount) { 1000 }
				price2 = Mock.new('Price2')
				price2.__next(:purpose) { 'Purpose2' }
				price2.__next(:amount) { 2000 }
				freetext = ToSMock.new('Freetext')
				freetext.__next(:type) { 'Bezeichnung' }
				freetext.__next(:to_s) { 'The FreeText' }
				item.__next(:line_no) { 'The Line Number' }
				item.__next(:ids) { {'ACC' => '12345'} }
				item.__next(:qty) { 'Quantity' }
				item.__next(:prices) { [price1, price2] }
				item.__next(:free_texts) { [freetext] }
				xml.__next(:add_element) { |xml_item|
					assert_instance_of(REXML::Element, xml_item)
					assert_equal('DeliveryItem', xml_item.name)
					assert_equal(6, xml_item.elements.size)
					line_no = xml_item.elements[1]
					assert_equal('LineNo', line_no.name)
					assert_equal('The Line Number', line_no.text)
					part_id = xml_item.elements[2]
					assert_equal('PartId', part_id.name)
					assert_equal(1, part_id.elements.size)
					ident_no = part_id.elements[1]
					assert_equal('IdentNo', ident_no.name)
					assert_equal(1, ident_no.attributes.size)
					assert_equal('ACC', ident_no.attributes['Domain'])
					assert_equal('12345', ident_no.text)
					qty = xml_item.elements[3]
					assert_equal('Qty', qty.name)
					assert_equal('Quantity', qty.text)
					xml_price1 = xml_item.elements[4]
					assert_equal('Price', xml_price1.name)
					xml_price2 = xml_item.elements[5]
					assert_equal('Price', xml_price2.name)
					xml_freetext = xml_item.elements[6]
					assert_equal('FreeText', xml_freetext.name)
					assert_equal(1, xml_freetext.attributes.size)
					assert_equal('Bezeichnung', xml_freetext.attributes['Type'])
					assert_equal('The FreeText', xml_freetext.text)
				}
				BddXml._xml_add_delivery_item(xml, item)
				xml.__verify
				item.__verify
			end
			def test__xml_add_item_price__positive
				xml_item = Mock.new('XmlItem')
				price = Mock.new('Price')
				price.__next(:purpose) { 'BruttoPreis' }
				price.__next(:amount) { 1005 }
				xml_item.__next(:add_element) { |xml_price|
					assert_instance_of(REXML::Element, xml_price)
					assert_equal('Price', xml_price.name)
					assert_equal(1, xml_price.attributes.size)
					assert_equal('BruttoPreis', xml_price.attributes['Purpose'])
					assert_equal('10.05', xml_price.text)
				}
				BddXml._xml_add_item_price(xml_item, price)
				xml_item.__verify
				price.__verify
			end
			def test__xml_add_item_price__negative
				xml_item = Mock.new('XmlItem')
				price = Mock.new('Price')
				price.__next(:purpose) { 'Grundrabatt' }
				price.__next(:amount) { -150 }
				xml_item.__next(:add_element) { |xml_price|
					assert_instance_of(REXML::Element, xml_price)
					assert_equal('Price', xml_price.name)
					assert_equal(1, xml_price.attributes.size)
					assert_equal('Grundrabatt', xml_price.attributes['Purpose'])
					assert_equal('-1.50', xml_price.text)
				}
				BddXml._xml_add_item_price(xml_item, price)
				xml_item.__verify
				price.__verify
			end
		end
	end
end
