#!/usr/bin/env ruby
# Conversion::TestBddGeh -- xmlconv2 -- 18.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/bdd_geh'
require 'flexmock'
require 'mock'

module XmlConv
  module Conversion
    class TestBddGeh < Test::Unit::TestCase
      def test_convert__delivery
        bdd = FlexMock.new
        bsr = FlexMock.new
        delivery = FlexMock.new
        delivery.mock_handle(:status_date) { }
        delivery.mock_handle(:customer_id) { '12345' }
        delivery.mock_handle(:reference_id) { '54321' }
        delivery.mock_handle(:parties) { [] }
        delivery.mock_handle(:items) { [] }
        delivery.mock_handle(:prices) { [] }
        delivery.mock_handle(:free_text) { } 
        delivery.mock_handle(:agreement) { }
        bsr.mock_handle(:timestamp) { }
        bsr.mock_handle(:verb) { }
        bsr.mock_handle(:noun) { }
        bsr.mock_handle(:parties) { [] }
        bdd.mock_handle(:bsr) { bsr }
        bdd.mock_handle(:deliveries) { [delivery] }
        bdd.mock_handle(:invoices) { [] }
        xml_doc = BddGeh.convert(bdd)
        assert_instance_of(REXML::Document, xml_doc)
        decl = "<?xml version='1.0' encoding='UTF-8'?>"
        assert_equal(decl, xml_doc.xml_decl.to_s)
        root = xml_doc.root
        assert_instance_of(REXML::Element, root)
        assert_equal('OrderResponse', root.name)
        assert_equal(2, root.elements.size)
        xml_header = root.elements[1]
        assert_instance_of(REXML::Element, xml_header)
        assert_equal('OrderResponseHeader', xml_header.name)
        xml_delivery = root.elements[2]
        assert_instance_of(REXML::Element, xml_delivery)
        assert_equal('OrderResponseDetail', xml_delivery.name)
        xml_responselist = xml_delivery.elements[1]
        assert_equal('ListOfOrderResponseItemDetail', xml_responselist.name)
      end
      def test__xml_add_bdd_delivery
        delivery = FlexMock.new
        party = FlexMock.new
        name = FlexMock.new
        agreement = FlexMock.new
        agreement.mock_handle(:terms_cond) { 'Terms and Conditions' }
        name.mock_handle(:text) { 'NameText' }
        name.mock_handle(:to_s) { 'NameString' }
        party.mock_handle(:role)  { 'Seller' }
        party.mock_handle(:party_id) { '12345' }
        party.mock_handle(:name)  { name }
        party.mock_handle(:address) { }
        party.mock_handle(:employee) { }
        delivery.mock_handle(:customer_id) { '0000405477' }
        delivery.mock_handle(:status) { 'Confirmed' }
        delivery.mock_handle(:status_date) { Time.local(2006, 5, 11, 2, 7, 19) }
        delivery.mock_handle(:reference_id) { 'B-1299545' }
        delivery.mock_handle(:parties) { [party] }
        delivery.mock_handle(:items) { [] } 
        delivery.mock_handle(:prices) { [] }
        delivery.mock_handle(:free_text) { }
        delivery.mock_handle(:agreement) { agreement }
        response = REXML::Element.new('OrderResponse')
        BddGeh._xml_add_bdd_delivery(response, delivery)
        assert_equal(2, response.elements.size)
        xml_header = response.elements[1]
        assert_equal(4, xml_header.elements.size)
      end
      def test__xml_add_delivery_header
        delivery = FlexMock.new
        party1 = FlexMock.new
        party2 = FlexMock.new
        party3 = FlexMock.new
        name = FlexMock.new
        name.mock_handle(:text) { 'NameText' }
        name.mock_handle(:to_s) { 'NameString' }
        party1.mock_handle(:role)  { 'Seller' }
        party1.mock_handle(:party_id) { '12345' }
        party1.mock_handle(:name)  { name }
        party1.mock_handle(:address) { }
        party1.mock_handle(:employee) { }
        party1.mock_handle(:parties) { [] }
        party2.mock_handle(:role)  { 'Customer' }
        party2.mock_handle(:party_id) { '54321' }
        party2.mock_handle(:name)  { name }
        party2.mock_handle(:address) { }
        party2.mock_handle(:employee) { }
        party3.mock_handle(:role)  { 'BillTo' }
        party3.mock_handle(:party_id) { '54321' }
        party3.mock_handle(:name)  { name }
        party3.mock_handle(:address) { }
        party3.mock_handle(:employee) { }
        party3.mock_handle(:parties) { [] }
        party2.mock_handle(:parties) { [party3] }
        delivery.mock_handle(:customer_id) { '0000405477' }
        delivery.mock_handle(:status) { 'Confirmed' }
        delivery.mock_handle(:status_date) { Time.local(2006, 5, 11, 2, 7, 19) }
        delivery.mock_handle(:reference_id) { 'B-1299545' }
        delivery.mock_handle(:parties) { [party1, party2] }
        response = REXML::Element.new('OrderResponse')
        BddGeh._xml_add_delivery_header(response, delivery)
        assert_equal(1, response.elements.size)
        xml_header = response.elements[1]
        xml_response_id = xml_header.elements[1]
        expected = '<OrderResponseNumber><BuyerOrderResponseNumber>0000405477</BuyerOrderResponseNumber></OrderResponseNumber>'
        assert_equal(expected, xml_response_id.to_s)
        xml_reference_id = xml_header.elements[2]
        expected = '<OrderReference><Reference><RefNum>B-1299545</RefNum></Reference></OrderReference>'
        assert_equal(expected, xml_reference_id.to_s)
        xml_issue_date = xml_header.elements[3]
        expected = '<OrderResponseIssueDate>20060511020719</OrderResponseIssueDate>'
        xml_party1 = xml_header.elements[4]
        assert_equal('SellerParty', xml_party1.name)
        xml_party2 = xml_header.elements[5]
        assert_equal('BuyerParty', xml_party2.name)
        assert_equal(5, xml_header.elements.size)
      end
      def test__xml_add_bdd_party
        party1 = FlexMock.new
        party2 = FlexMock.new
        xml = FlexMock.new
        address = FlexMock.new
        name = FlexMock.new
        name.mock_handle(:first) { 'Grossauer Elektro-Handels AG' }
        name.mock_handle(:last) { }
        employee = FlexMock.new
        employee.mock_handle(:role) { 'Employee' }
        employee.mock_handle(:ids) { [] }
        employee.mock_handle(:name) { 'Danilo Lanzafame' }
        employee.mock_handle(:address) { }
        employee.mock_handle(:parties) { [] }
        address.mock_handle(:lines) { ['Grossauer Elektro-Handels AG',
          'Address Line'] }
        address.mock_handle(:city)  { 'Heiden' }
        address.mock_handle(:zip_code)  { '9410' }
        address.mock_handle(:country) { 'CH' } 
        party1.mock_handle(:role) { 'Customer' }
        party1.mock_handle(:parties) { [party2] }
        party1.mock_handle(:name) { 'Grossauer Elektro-Handels AG' }
        party1.mock_handle(:employee) { employee }
        party2.mock_handle(:role) { 'ShipTo' }
        party2.mock_handle(:party_id) { 105446 }
        party2.mock_handle(:address) { address }
        xml.mock_handle(:add_element, 1) { |xml_party|
          assert_instance_of(REXML::Element, xml_party)
          expected = '<ShipToParty><Party><PartyID><Identifier><Ident>105446</Ident></Identifier></PartyID><NameAddress><Name1>Grossauer Elektro-Handels AG</Name1><Street>Address Line</Street><PostalCode>9410</PostalCode><City>Heiden</City></NameAddress><OrderContact><Contact><ContactName>Danilo Lanzafame</ContactName></Contact></OrderContact></Party></ShipToParty>'
          assert_equal(expected, xml_party.to_s)
        }
        BddGeh._xml_add_bdd_party(xml, party1)
        xml.mock_verify
      end
      def test__xml_add_item
        xml = FlexMock.new
        item = FlexMock.new
        part_info = FlexMock.new
        price1 = FlexMock.new
        price1.mock_handle(:amount) { 12345 }
        part_info.mock_handle(:dimension) { 'the Dimension' }
        part_info.mock_handle(:value) { 'the Value' }
        item.mock_handle(:line_no) { '10' }
        item.mock_handle(:ids) { [
          ['EAN-Nummer', '123123123'],
          ['ET-Nummer', '123 890 390'],
        ] }
        item.mock_handle(:part_infos) { [part_info] }
        item.mock_handle(:qty) { 3 }
        item.mock_handle(:get_price) { |purpose|
          {
            'BruttoPreisME' => price1, 
          }[purpose] 
        }
        item.mock_handle(:free_text) { }
        item.mock_handle(:delivery_date) { Date.new(2006,5,16) }
        xml.mock_handle(:add_element) { |xml_item|
          assert_instance_of(REXML::Element, xml_item)
          assert_equal('OrderResponseItemDetail', xml_item.name)
          assert_equal(3, xml_item.elements.size)
          xml_base = xml_item.elements[1]
          assert_equal('BaseItemDetail', xml_base.name)
          xml_pricing = xml_item.elements[2]
          assert_equal('PricingDetail', xml_pricing.name)
          xml_delivery = xml_item.elements[3]
          assert_equal('DeliveryDetail', xml_delivery.name)
        }
        BddGeh._xml_add_item(xml, item)
        xml.mock_verify
      end
      def test__xml_add_base_item_detail
        xml = FlexMock.new
        item = FlexMock.new
        price = FlexMock.new
        item.mock_handle(:line_no) { '10' }
        item.mock_handle(:ids) { [
          ['EAN-Nummer', '123123123'],
          ['ET-Nummer', '123 890 390'],
        ] }
        item.mock_handle(:qty) { 3 }
        xml.mock_handle(:add_element) { |xml_detail|
          assert_instance_of(REXML::Element, xml_detail)
          assert_equal('BaseItemDetail', xml_detail.name)
          assert_equal(3, xml_detail.elements.size)
          xml_line_num = xml_detail.elements[1]
          expected = '<LineItemNum><BuyerLineItemNum>10</BuyerLineItemNum></LineItemNum>'
          assert_equal(expected, xml_line_num.to_s)
          xml_ids = xml_detail.elements[2]
          expected = '<ItemIdentifiers><PartNumbers><SellerPartNumber><PartNum><PartID>123123123</PartID></PartNum></SellerPartNumber><BuyerPartNumber><PartNum><PartID>123 890 390</PartID></PartNum></BuyerPartNumber></PartNumbers></ItemIdentifiers>' 
          assert_equal(expected, xml_ids.to_s)
          xml_qty = xml_detail.elements[3]
          expected = '<TotalQuantity><Quantity><QuantityValue>3</QuantityValue><UnitOfMeasurement><UOMCoded>EA</UOMCoded></UnitOfMeasurement></Quantity></TotalQuantity>'
          assert_equal(expected, xml_qty.to_s)
        }
        BddGeh._xml_add_base_item_detail(xml, item)
        xml.mock_verify
      end
      def test__xml_add_pricing_detail
        xml = FlexMock.new
        item = FlexMock.new
        part_info = FlexMock.new
        price1 = FlexMock.new
        price1.mock_handle(:amount) { 3233 }
        price2 = FlexMock.new
        price2.mock_handle(:amount) { 9699 }
        item.mock_handle(:part_infos) { [part_info] }
        item.mock_handle(:qty) { 3 }
        item.mock_handle(:get_price) { |purpose|
          {
            'BruttoPreisME' => price1, 
            'BruttoPreis'   => price2,
          }[purpose] 
        }
        item.mock_handle(:free_text) { }
        xml.mock_handle(:add_element) { |xml_item|
          assert_instance_of(REXML::Element, xml_item)
          assert_equal('PricingDetail', xml_item.name)
          assert_equal(2, xml_item.elements.size)
          xml_list = xml_item.elements[1]
          expected = '<ListOfPrice><Price><UnitPrice><Currency><CurrencyCoded>CHF</CurrencyCoded></Currency><UnitPriceValue>32.33</UnitPriceValue></UnitPrice></Price></ListOfPrice>'
          assert_equal(expected, xml_list.to_s)
          xml_value = xml_item.elements[2]
          expected = '<TotalValue><MonetaryValue><MonetaryAmount>96.99</MonetaryAmount></MonetaryValue></TotalValue>'
          assert_equal(expected, xml_value.to_s)
        }
        BddGeh._xml_add_pricing_detail(xml, item)
        xml.mock_verify
      end
      def test__xml_add_delivery_detail
        xml = FlexMock.new
        item = FlexMock.new
        part_info = FlexMock.new
        item.mock_handle(:delivery_date) { Date.new(2006,5,16) }
        xml.mock_handle(:add_element) { |xml_item|
          assert_instance_of(REXML::Element, xml_item)
          expected = '<DeliveryDetail><ListOfScheduleLine><ScheduleLine><RequestedDeliveryDate>20060516</RequestedDeliveryDate></ScheduleLine></ListOfScheduleLine></DeliveryDetail>'
          assert_equal(expected, xml_item.to_s)
        }
        BddGeh._xml_add_delivery_detail(xml, item)
        xml.mock_verify
      end
      def test_convert__invoice
        bdd = FlexMock.new
        bsr = FlexMock.new
        invoice = FlexMock.new
        invoice.mock_handle(:status_date) { }
        invoice.mock_handle(:invoice_id) { ['Invoice', '12345'] }
        invoice.mock_handle(:delivery_id) { ['ACC', '54321'] }
        invoice.mock_handle(:seller) { }
        invoice.mock_handle(:items) { [] }
        invoice.mock_handle(:get_price) { }
        invoice.mock_handle(:free_text) { } 
        invoice.mock_handle(:agreement) { }
        bsr.mock_handle(:timestamp) { }
        bsr.mock_handle(:verb) { }
        bsr.mock_handle(:noun) { }
        bsr.mock_handle(:parties) { [] }
        bdd.mock_handle(:bsr) { bsr }
        bdd.mock_handle(:deliveries) { [] }
        bdd.mock_handle(:invoices) { [ invoice ] }
        xml_doc = BddGeh.convert(bdd)
        assert_instance_of(REXML::Document, xml_doc)
        decl = "<?xml version='1.0' encoding='UTF-8'?>"
        assert_equal(decl, xml_doc.xml_decl.to_s)
        root = xml_doc.root
        assert_instance_of(REXML::Element, root)
        assert_equal('Invoice', root.name)
        xml_header = root.elements[1]
        assert_instance_of(REXML::Element, xml_header)
        assert_equal('InvoiceHeader', xml_header.name)
        xml_delivery = root.elements[2]
        assert_instance_of(REXML::Element, xml_delivery)
        assert_equal('InvoiceDetail', xml_delivery.name)
        xml_summary = root.elements[3]
        assert_instance_of(REXML::Element, xml_summary)
        assert_equal('InvoiceSummary', xml_summary.name)
        assert_equal(3, root.elements.size)
      end
      def test__xml_add_bdd_invoice
        delivery = FlexMock.new
        party = FlexMock.new
        name = FlexMock.new
        agreement = FlexMock.new
        agreement.mock_handle(:terms_cond) { 'Terms and Conditions' }
        name.mock_handle(:text) { 'NameText' }
        name.mock_handle(:to_s) { 'NameString' }
        party.mock_handle(:role)  { 'Seller' }
        party.mock_handle(:party_id) { '12345' }
        party.mock_handle(:name)  { name }
        party.mock_handle(:address) { }
        party.mock_handle(:employee) { }
        delivery.mock_handle(:invoice_id) { ['Invoice', '0000405477'] }
        delivery.mock_handle(:status) { 'Confirmed' }
        delivery.mock_handle(:status_date) { Time.local(2006, 5, 11, 2, 7, 19) }
        delivery.mock_handle(:delivery_id) { ['ACC', 'B-1299545'] }
        delivery.mock_handle(:seller) { party }
        delivery.mock_handle(:items) { [] } 
        delivery.mock_handle(:get_price) { }
        delivery.mock_handle(:free_text) { }
        delivery.mock_handle(:agreement) { agreement }
        invoice = REXML::Element.new('Invoice')
        BddGeh._xml_add_bdd_invoice(invoice, delivery)
        xml_header = invoice.elements[1]
        assert_equal('InvoiceHeader', xml_header.name)
        assert_equal(4, xml_header.elements.size)
        xml_detail = invoice.elements[2]
        assert_equal('InvoiceDetail', xml_detail.name)
        assert_equal(1, xml_detail.elements.size)
        xml_summary = invoice.elements[3]
        assert_equal('InvoiceSummary', xml_summary.name)
        assert_equal(2, xml_summary.elements.size)
        assert_equal(3, invoice.elements.size)
      end
      def test__xml_add_invoice_header
        invoice = FlexMock.new
        party1 = FlexMock.new
        party2 = FlexMock.new
        name = FlexMock.new
        name.mock_handle(:text) { 'NameText' }
        name.mock_handle(:to_s) { 'Test AG' }
        party1.mock_handle(:role)  { 'Seller' }
        party1.mock_handle(:party_id) { '100' }
        party1.mock_handle(:name)  { name }
        party1.mock_handle(:address) { }
        party1.mock_handle(:employee) { }
        party2.mock_handle(:role)  { 'Customer' }
        party2.mock_handle(:party_id) { '54321' }
        party2.mock_handle(:name)  { name }
        party2.mock_handle(:address) { }
        party2.mock_handle(:employee) { }
        invoice.mock_handle(:invoice_id) { ['Invoice', '0038379197'] }
        invoice.mock_handle(:delivery_id) { ['ACC', 'B-1298089'] }
        invoice.mock_handle(:status) { 'Confirmed' }
        invoice.mock_handle(:status_date) { Time.local(2006, 5, 12, 7, 32, 48) }
        invoice.mock_handle(:seller) { party1 }
        xml_invoice = REXML::Element.new('Invoice')
        BddGeh._xml_add_invoice_header(xml_invoice, invoice)
        assert_equal(1, xml_invoice.elements.size)
        xml_header = xml_invoice.elements[1]
        xml_reference = xml_header.elements[1]
        expected = '<InvoiceNumber><Reference><RefNum>0038379197</RefNum></Reference></InvoiceNumber>'
        assert_equal(expected, xml_reference.to_s)
        xml_date = xml_header.elements[2]
        expected = '<InvoiceIssueDate>20060512073248</InvoiceIssueDate>'
        assert_equal(expected, xml_date.to_s)
        xml_refs = xml_header.elements[3]
        assert_equal('InvoiceReferences', xml_refs.name)
        xml_party = xml_header.elements[4]
        expected = '<SellerParty><Party><PartyID><Identifier><Ident>100</Ident></Identifier></PartyID></Party></SellerParty>'
        assert_equal(expected, xml_party.to_s)
        assert_equal(4, xml_header.elements.size)
      end
      def test__xml_add_invoice_reference
        xml = FlexMock.new
        invoice = FlexMock.new
        invoice.mock_handle(:delivery_id) { ['ACC', 'B-1298089'] }
        xml.mock_handle(:add_element, 1) { |xml_refs|
          assert_equal('InvoiceReferences', xml_refs.name) 
          xml_order_ref = xml_refs.elements[1]
          expected = '<PurchaseOrderReference><PurchaseOrderNumber><Reference><RefNum>B-1298089</RefNum></Reference></PurchaseOrderNumber></PurchaseOrderReference>'
          assert_equal(expected, xml_order_ref.to_s)
          expected = '<AccountNumber><Reference><RefNum>01000131751001054463837919705010072808</RefNum></Reference></AccountNumber>'
          xml_account = xml_refs.elements[2]
          assert_equal(expected, xml_account.to_s)
          assert_equal(2, xml_refs.elements.size) 
        }
        BddGeh._xml_add_invoice_references(xml, invoice)
        xml.mock_verify
      end
      def test__xml_add_invoice_detail
        xml = FlexMock.new
        invoice = FlexMock.new
        invoice.mock_handle(:items) { [] }
        xml.mock_handle(:add_element, 1) { |xml_detail|
          assert_equal('InvoiceDetail', xml_detail.name) 
          assert_equal(1, xml_detail.elements.size)
          xml_detail_list = xml_detail.elements[1]
          assert_equal('ListOfInvoiceItemDetail', xml_detail_list.name)
        }
        BddGeh._xml_add_invoice_detail(xml, invoice)
        xml.mock_verify
      end
      def test__xml_add_invoice_item
        xml = FlexMock.new
        item = FlexMock.new
        part_info = FlexMock.new
        price1 = FlexMock.new
        price1.mock_handle(:amount) { 12345 }
        price2 = FlexMock.new
        price2.mock_handle(:amount) { 54321 }
        part_info.mock_handle(:dimension) { 'the Dimension' }
        part_info.mock_handle(:value) { 'the Value' }
        item.mock_handle(:line_no) { '10' }
        item.mock_handle(:ids) { [
          ['EAN-Nummer', '123123123'],
          ['ET-Nummer', '123 890 390'],
        ] }
        item.mock_handle(:part_infos) { [part_info] }
        item.mock_handle(:qty) { 3 }
        item.mock_handle(:get_price) { |purpose|
          {
            'BruttoPreisME' => price1, 
            'BruttoPreis'   => price2,
          }[purpose] 
        }
        item.mock_handle(:free_text) { }
        item.mock_handle(:delivery_date) { Date.new(2006,5,16) }
        xml.mock_handle(:add_element) { |xml_item|
          assert_instance_of(REXML::Element, xml_item)
          assert_equal('InvoiceItemDetail', xml_item.name)
          assert_equal(2, xml_item.elements.size)
          xml_base = xml_item.elements[1]
          assert_equal('InvoiceBaseItemDetail', xml_base.name)
          xml_pricing = xml_item.elements[2]
          assert_equal('InvoicePricingDetail', xml_pricing.name)
          xml_total = xml_pricing.elements[2]
          assert_equal('InvoiceCurrencyTotalValue', xml_total.name)
        }
        BddGeh._xml_add_invoice_item(xml, item)
        xml.mock_verify
      end
      def test__xml_add_invoice_summary
        xml = FlexMock.new
        price_net = FlexMock.new
        price_net.mock_handle(:amount) { 1262325 }
        price_tax = FlexMock.new
        price_tax.mock_handle(:amount) { 95937 }
        price_total = FlexMock.new
        price_total.mock_handle(:amount) { 1358262 }
        invoice = FlexMock.new
        invoice.mock_handle(:items) { ['item1', 'item2'] }
        invoice.mock_handle(:get_price) { |purpose|
          {
            'Endbetrag'       =>  price_total,
            'Mehrwertsteuer'  =>  price_tax,
            'SummePositionen' =>  price_net,
          }[purpose]
        }
        xml.mock_handle(:add_element, 1) { |xml_summary|
          assert_equal('InvoiceSummary', xml_summary.name)
          xml_lines = xml_summary.elements[1]
          expected = '<NumberOfLines>2</NumberOfLines>'
          assert_equal(expected, xml_lines.to_s)
          xml_totals = xml_summary.elements[2]
          assert_equal('InvoiceTotals', xml_totals.name)
          xml_net = xml_totals.elements[1]
          expected = '<NetValue><MonetaryValue><MonetaryAmount>12623.25</MonetaryAmount></MonetaryValue></NetValue>'
          assert_equal(expected, xml_net.to_s)
          xml_tax = xml_totals.elements[2]
          expected = '<TotalTax><MonetaryValue><MonetaryAmount>959.37</MonetaryAmount></MonetaryValue></TotalTax>'
          assert_equal(expected, xml_tax.to_s)
          xml_total = xml_totals.elements[3]
          expected = '<TotalAmountPlusTax><MonetaryValue><MonetaryAmount>13582.62</MonetaryAmount></MonetaryValue></TotalAmountPlusTax>'
          assert_equal(expected, xml_total.to_s)
          assert_equal(3, xml_totals.elements.size)
          assert_equal(2, xml_summary.elements.size)
        }
        BddGeh._xml_add_invoice_summary(xml, invoice)
        xml.mock_verify
      end
    end
  end
end
