#!/usr/bin/env ruby
# TestXmlBdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/xml_bdd'

module XmlConv
	module Conversion
		class TestXmlBdd < Test::Unit::TestCase
			def setup
				@src = <<-EOS
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE BDD SYSTEM "ABB BDD.dtd">
<BDD Version="2">
  <BSR Version="3">
    <Timestamp Zone="+1">20040416151630</Timestamp>
    <Verb>Place</Verb>
    <Noun>Order</Noun>
    <Party Role="Customer" Version="2">
      <Name>Winterhalter + Fenner AG</Name>
      <PartyId Domain="ACC">%%%99999%%% Kundennummer ElectroLAN</PartyId>
    </Party>
  </BSR>
  <Delivery Version="3">
    <Status Date="20040416151441" Domain="">Order</Status>
    <DeliveryId Domain="Customer">B-465178 W</DeliveryId>
    <Party Version="2" Role="Seller">
      <Name>Plica AG</Name>
      <Address>
        <AddressLine>Zürcherstr. 350/Postfach 173</AddressLine>
        <City>Frauenfeld</City>
        <ZipCode Domain="">8501</ZipCode>
      </Address>
    </Party>
    <Party Version="2" Role="Customer">
      <Name>Winterhalter + Fenner AG</Name>
      <Phone Domain="Business">01 / 839 58 44</Phone>
      <Address>
        <AddressLine>Birgistrasse 10</AddressLine>
        <City>Wallisellen</City>
        <ZipCode Domain="CH">8304</ZipCode>
      </Address>
      <Party Role="Employee">
        <Name>
          <LastName>Russo Giovanni</LastName>
        </Name>
        <Competency>Sachbearbeiter</Competency>
      </Party>
      <Party Role="ShipTo">
        <Name>Winterhalter + Fenner AG</Name>
        <PartyId Domain="ACC">%%%99999%%% Lieferadressnummer</PartyId>
        <Address>
          <AddressLine>Filiale Wallisellen</AddressLine>
          <AddressLine>Hertistrasse 31</AddressLine>
          <City>Wallisellen</City>
          <ZipCode Domain="CH">8304</ZipCode>
        </Address>
      </Party>
      <Party Role="BillTo">
        <Name>Winterhalter + Fenner AG</Name>
        <PartyId Domain="ACC">%%%99999%%% Rechnungsadressnummer</PartyId>
        <Address>
          <AddressLine>Birgistrasse 10</AddressLine>
          <City>Wallisellen</City>
          <ZipCode Domain="CH">8304</ZipCode>
        </Address>
      </Party>
    </Party>
    <DeliveryItem>
      <LineNo>2508466</LineNo>
      <PartId>
        <IdentNo Domain="ET-NUMMER">125301307</IdentNo>
        <IdentNo Domain="LIEFERANTENARTIKEL">15.0205.025</IdentNo>
      </PartId>
      <Qty>7200</Qty>
      <FreeText Type="BEZEICHNUNG">KRF-ROHR PE O/DRAHT M25 OR</FreeText>
      <DeliveryDate>14.04.2004</DeliveryDate>
    </DeliveryItem>
    <DeliveryItem>
      <LineNo>2508467</LineNo>
      <PartId>
        <IdentNo Domain="ET-NUMMER">125301607</IdentNo>
        <IdentNo Domain="LIEFERANTENARTIKEL">15.0202.550</IdentNo>
      </PartId>
      <Qty>900</Qty>
      <FreeText Type="BEZEICHNUNG">KRF-ROHR PE O/DRAHT M50 OR</FreeText>
      <DeliveryDate>SOFORT</DeliveryDate>
    </DeliveryItem>
    <DeliveryItem>
      <LineNo>2508468</LineNo>
      <PartId>
        <IdentNo Domain="ET-NUMMER">125301707</IdentNo>
        <IdentNo Domain="LIEFERANTENARTIKEL">15.0202.563</IdentNo>
      </PartId>
      <Qty>250</Qty>
      <FreeText Type="BEZEICHNUNG">KRF-ROHR PE O/DRAHT M63 OR</FreeText>
      <DeliveryDate>14.04.2004</DeliveryDate>
    </DeliveryItem>
  </Delivery>
</BDD>
				EOS
				@xml_doc = REXML::Document.new(@src)
			end
			def test_xml2bdd
				bdd = XmlBdd.convert(@xml_doc)
				assert_instance_of(Model::Bdd, bdd)
				bsr = bdd.bsr
				assert_instance_of(Model::Bsr, bsr)
				delivery = bdd.deliveries.first
				assert_instance_of(Model::Delivery, delivery)
				assert_equal(bsr, delivery.bsr)
			end
			def test__bdd_add_xml_bsr
				xml_bsr = REXML::XPath.first(@xml_doc, 'BDD/BSR')
				bdd = Model::Bdd.new
				XmlBdd._bdd_add_xml_bsr(bdd, xml_bsr)
				bsr = bdd.bsr
				assert_instance_of(Model::Bsr, bsr)
				parties = bsr.parties
				assert_instance_of(Model::Party, parties.first)
				assert_equal('%%%99999%%% Kundennummer ElectroLAN', bsr.bsr_id)
			end
			def test__container_add_xml_party__seller
				xml_party = REXML::XPath.first(@xml_doc, 'BDD/Delivery/Party')
				delivery = Model::Delivery.new
				XmlBdd._container_add_xml_party(delivery, xml_party)
				seller = delivery.seller
				assert_instance_of(Model::Party, seller)
				assert_instance_of(Model::Name, seller.name)
				assert_equal('Plica AG', seller.name.to_s)
				seller_addr = seller.address
				assert_instance_of(Model::Address, seller_addr)
				assert_equal(['Zürcherstr. 350/Postfach 173'], seller_addr.lines)
				assert_equal('Frauenfeld', seller_addr.city)
				assert_equal('8501', seller_addr.zip_code)
			end
			def test__container_add_xml_party__customer
				xml_party = REXML::XPath.first(@xml_doc, "BDD/Delivery/Party[@Role='Customer']")
				delivery = Model::Delivery.new
				XmlBdd._container_add_xml_party(delivery, xml_party)
				customer = delivery.customer	
				assert_instance_of(Model::Party, customer)
				cust_addr = customer.address
				assert_instance_of(Model::Address, cust_addr)
				assert_equal(['Birgistrasse 10'], cust_addr.lines)
				assert_equal('Wallisellen', cust_addr.city)
				assert_equal('8304', cust_addr.zip_code)
				assert_equal(3, customer.parties.size)
				employee = customer.employee
				assert_instance_of(Model::Party, employee)
				assert_instance_of(Model::Name, employee.name)
				assert_equal('Russo Giovanni', employee.name.last)
				assert_equal('Russo Giovanni', employee.name.to_s)
				ship_to = customer.ship_to
				assert_instance_of(Model::Party, ship_to)
				ship_to_addr = ship_to.address
				assert_instance_of(Model::Address, ship_to_addr)
				expected = [
					'Filiale Wallisellen',	
					'Hertistrasse 31',
				]
				assert_equal(expected, ship_to_addr.lines)
				bill_to = customer.bill_to
				assert_instance_of(Model::Party, bill_to)
				bill_to_addr = bill_to.address
				assert_instance_of(Model::Address, bill_to_addr)
			end
			def test__bdd_add_xml_delivery
				xml_delivery = REXML::XPath.first(@xml_doc, 'BDD/Delivery')
				bdd = Model::Bdd.new
				XmlBdd._bdd_add_xml_delivery(bdd, xml_delivery)
				delivery = bdd.deliveries.first
				assert_instance_of(Model::Delivery, delivery)		
				assert_equal('B-465178 W', delivery.customer_id)
				seller = delivery.seller
				assert_instance_of(Model::Party, seller)
				customer = delivery.customer	
				assert_instance_of(Model::Party, customer)
				items = delivery.items
				assert_equal(3, items.size)
				item1 = items.first
				assert_instance_of(Model::DeliveryItem, item1)
				assert_equal('2508466', item1.line_no)
				assert_equal('125301307', item1.et_nummer_id)
				assert_equal(7200, item1.qty)
				assert_equal(Date.new(2004,4,14), item1.delivery_date)
				item2 = items.at(1)
				assert_instance_of(Model::DeliveryItem, item2)
				assert_equal('2508467', item2.line_no)
				assert_equal('125301607', item2.et_nummer_id)
				assert_equal(900, item2.qty)
				assert_equal(Date.today, item2.delivery_date)
			end
			def test_parse
				document = XmlBdd.parse(@src)
				assert_instance_of(REXML::Document, document)
			end
		end
	end
end
