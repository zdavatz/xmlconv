#!/usr/bin/env ruby
# Integration::TestXmlI2 -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/transaction'
require 'util/destination'
require 'conversion/xml_bdd'
require 'conversion/bdd_i2'
require 'mock'

module XmlConv
	module Integration
		class TestXmlI2 < Test::Unit::TestCase
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
				@target_dir = File.expand_path('data/xml_i2', 
					File.dirname(__FILE__))
				clear_dir
			end
			def teardown
				clear_dir
			end
			def clear_dir
				if(File.exist?(@target_dir))
					FileUtils.rm_r(@target_dir)
				end
			end
			def test_xml_i2
				bdd = Conversion::XmlBdd.convert(@xml_doc)
				i2_doc = Conversion::BddI2.convert(bdd)
				result = i2_doc.to_s.split("\n")
				expected = <<-EOS
001:EPIN_PLICA
002:ORDERX
003:220
010:#{Time.now.strftime('EPIN_PLICA_%Y%m%d%H%M%S.dat')}
100:%%%99999%%% Kundennummer ElectroLAN
101:B-465178 W
201:EP
220:Russo Giovanni
201:DP
202:%%%99999%%% Lieferadressnummer
220:Winterhalter + Fenner AG
221:Filiale Wallisellen
222:Hertistrasse 31
223:Wallisellen
225:8304
201:BY
202:%%%99999%%% Rechnungsadressnummer
220:Winterhalter + Fenner AG
222:Birgistrasse 10
223:Wallisellen
225:8304
237:61
300:4
301:#{Date.today.strftime('%Y%m%d')}
500:2508466
501:125301307
520:7200
540:2
541:20040414
500:2508467
501:125301607
520:900
540:2
541:#{Date.today.strftime('%Y%m%d')}
500:2508468
501:125301707
520:250
540:2
541:20040414
				EOS
				expected.split("\n").each_with_index { |line, index|
					assert_equal(line, result[index])
				}
			end
			def test_execute_transaction
				cache = Mock.new('Cache')
				cache.__next(:store) { |persistable|
					assert_instance_of(Util::DestinationDir, persistable)
				}
				ODBA.cache_server = cache
				destination = Util::DestinationDir.new
				destination.path = @target_dir
				transaction = Util::Transaction.new
				transaction.reader = "XmlBdd"
				transaction.writer = "BddI2"
				transaction.input = @src
				transaction.destination = destination
				output = transaction.execute
				result = output.to_s.split("\n")
				expected = <<-EOS
001:EPIN_PLICA
002:ORDERX
003:220
010:#{Time.now.strftime('EPIN_PLICA_%Y%m%d%H%M%S.dat')}
100:%%%99999%%% Kundennummer ElectroLAN
101:B-465178 W
201:EP
220:Russo Giovanni
201:DP
202:%%%99999%%% Lieferadressnummer
220:Winterhalter + Fenner AG
221:Filiale Wallisellen
222:Hertistrasse 31
223:Wallisellen
225:8304
201:BY
202:%%%99999%%% Rechnungsadressnummer
220:Winterhalter + Fenner AG
222:Birgistrasse 10
223:Wallisellen
225:8304
237:61
300:4
301:#{Date.today.strftime('%Y%m%d')}
500:2508466
501:125301307
520:7200
540:2
541:20040414
500:2508467
501:125301607
520:900
540:2
541:#{Date.today.strftime('%Y%m%d')}
500:2508468
501:125301707
520:250
540:2
541:20040414
				EOS
				expected.split("\n").each_with_index { |line, index|
					assert_equal(line, result[index])
				}
				assert(File.exist?(@target_dir), 'Target Directory does not exist')
				entries = Dir.entries(@target_dir)
				assert_equal(3, entries.size)
				entry = entries.sort.last
				path = File.expand_path(entry, @target_dir)
				content = File.read(path)
				assert_equal(expected, content)
			end
		end
	end
end
