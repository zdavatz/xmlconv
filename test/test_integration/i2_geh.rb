#!/usr/bin/env ruby
# IntegrationTestI2Geh -- xmlconv2 -- 12.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/transaction'
require 'util/destination'
require 'conversion/bdd_geh'
require 'conversion/i2_bdd'
require 'mock'

module XmlConv
	module Util
		class DestinationHttp < Destination
			HTTP_CLASS = Mock.new('DestinationHttp::HTTP_CLASS')
		end
	end
	module Integration
		class TestI2Geh < Test::Unit::TestCase
			def test_i2_xml_confirm
				src = <<-EOS
"00" "Sender Identification" "Recipient Identification" 
	"20040628" "1159" "CONFIRM" "1"
"01" "456" "Receipt-Number" "20040627" "Order Number" 
	"Commission Number" "OC" "Employee" 
"02" "BY" "Name1" "Name2" "Street" "City" "AddressCode" "Country"
"02" "SE" "Name1" "Name2" "Street" "City" "AddressCode" "Country"
"02" "DP" "Name1" "Name2" "Street" "City" "AddressCode" "Country"
"05" "A single Header-Text"
"05" "Another single Header-Text"
"10" "10" "EAN13" "IdBuyer" "2" "20040630"
	"1" "2" "0.1" "0.2" "0.2" "0.4" "0.7" "1.4"
"10" "20" "EAN13" "IdBuyer" "2" "20040630" 
	"1" "2" "0.1" "0.2" "0.2" "0.4" "0.7" "1.4" 
"10" "30" "EAN13" "IdBuyer" "2" "20040630" 
	"1" "2" "0.1" "0.2" "0.2" "0.4" "0.7" "1.4" 
"90" "4.2" "7.6" "0.32" "4.52" "Agreement"
				EOS
				ast = Conversion::I2Bdd.parse(src)
				bdd = Conversion::I2Bdd.convert(ast)
				conversion = Conversion::BddGeh.convert(bdd)
				assert_instance_of(Array, conversion)
				assert_equal(1, conversion.size)
        xml = conversion.first
				assert_instance_of(REXML::Document, xml)
        expected = <<-EOS
  <?xml version='1.0' encoding='UTF-8'?>

  <OrderResponse>
    <OrderResponseHeader>
      <OrderResponseNumber>
        <BuyerOrderResponseNumber>Commission Number</BuyerOrderResponseNumber>
      </OrderResponseNumber>
      <OrderReference>
        <Reference>
          <RefNum>Order Number</RefNum>
        </Reference>
      </OrderReference>
      <OrderResponseIssueDate>20040627000000</OrderResponseIssueDate>
      <SellerParty>
        <Party>
          <PartyID>
            <Identifier>
              <Ident>667</Ident>
            </Identifier>
          </PartyID>
          <NameAddress>
            <Name1>Name1</Name1>
            <Name2>Name2</Name2>
            <Street>Street</Street>
            <PostalCode>AddressCode</PostalCode>
            <City>City</City>
          </NameAddress>
        </Party>
      </SellerParty>
      <BuyerParty>
        <Party>
          <NameAddress>
            <Name1>Name1</Name1>
            <Name2>Name2</Name2>
            <Street>Street</Street>
            <PostalCode>AddressCode</PostalCode>
            <City>City</City>
          </NameAddress>
          <OrderContact>
            <Contact>
              <ContactName>Employee</ContactName>
            </Contact>
          </OrderContact>
        </Party>
      </BuyerParty>
      <ShipToParty>
        <Party>
          <NameAddress>
            <Name1>Name1</Name1>
            <Name2>Name2</Name2>
            <Street>Street</Street>
            <PostalCode>AddressCode</PostalCode>
            <City>City</City>
          </NameAddress>
          <OrderContact>
            <Contact>
              <ContactName>Employee</ContactName>
            </Contact>
          </OrderContact>
        </Party>
      </ShipToParty>
    </OrderResponseHeader>
    <OrderResponseDetail>
      <ListOfOrderResponseItemDetail>
        <OrderResponseItemDetail>
          <BaseItemDetail>
            <LineItemNum>
              <BuyerLineItemNum>10</BuyerLineItemNum>
            </LineItemNum>
            <ItemIdentifiers>
              <PartNumbers>
                <BuyerPartNumber>
                  <PartNum>
                    <PartID>IdBuyer</PartID>
                  </PartNum>
                </BuyerPartNumber>
                <SellerPartNumber>
                  <PartNum>
                    <PartID>EAN13</PartID>
                  </PartNum>
                </SellerPartNumber>
              </PartNumbers>
            </ItemIdentifiers>
            <TotalQuantity>
              <Quantity>
                <QuantityValue>2</QuantityValue>
                <UnitOfMeasurement>
                  <UOMCoded>EA</UOMCoded>
                </UnitOfMeasurement>
              </Quantity>
            </TotalQuantity>
          </BaseItemDetail>
          <PricingDetail>
            <ListOfPrice>
              <Price>
                <UnitPrice>
                  <Currency>
                    <CurrencyCoded>CHF</CurrencyCoded>
                  </Currency>
                  <UnitPriceValue>1.00</UnitPriceValue>
                </UnitPrice>
              </Price>
            </ListOfPrice>
            <TotalValue>
              <MonetaryValue>
                <MonetaryAmount>2.00</MonetaryAmount>
              </MonetaryValue>
            </TotalValue>
          </PricingDetail>
          <DeliveryDetail>
            <ListOfScheduleLine>
              <ScheduleLine>
                <RequestedDeliveryDate>20040630</RequestedDeliveryDate>
              </ScheduleLine>
            </ListOfScheduleLine>
          </DeliveryDetail>
        </OrderResponseItemDetail>
        <OrderResponseItemDetail>
          <BaseItemDetail>
            <LineItemNum>
              <BuyerLineItemNum>20</BuyerLineItemNum>
            </LineItemNum>
            <ItemIdentifiers>
              <PartNumbers>
                <BuyerPartNumber>
                  <PartNum>
                    <PartID>IdBuyer</PartID>
                  </PartNum>
                </BuyerPartNumber>
                <SellerPartNumber>
                  <PartNum>
                    <PartID>EAN13</PartID>
                  </PartNum>
                </SellerPartNumber>
              </PartNumbers>
            </ItemIdentifiers>
            <TotalQuantity>
              <Quantity>
                <QuantityValue>2</QuantityValue>
                <UnitOfMeasurement>
                  <UOMCoded>EA</UOMCoded>
                </UnitOfMeasurement>
              </Quantity>
            </TotalQuantity>
          </BaseItemDetail>
          <PricingDetail>
            <ListOfPrice>
              <Price>
                <UnitPrice>
                  <Currency>
                    <CurrencyCoded>CHF</CurrencyCoded>
                  </Currency>
                  <UnitPriceValue>1.00</UnitPriceValue>
                </UnitPrice>
              </Price>
            </ListOfPrice>
            <TotalValue>
              <MonetaryValue>
                <MonetaryAmount>2.00</MonetaryAmount>
              </MonetaryValue>
            </TotalValue>
          </PricingDetail>
          <DeliveryDetail>
            <ListOfScheduleLine>
              <ScheduleLine>
                <RequestedDeliveryDate>20040630</RequestedDeliveryDate>
              </ScheduleLine>
            </ListOfScheduleLine>
          </DeliveryDetail>
        </OrderResponseItemDetail>
        <OrderResponseItemDetail>
          <BaseItemDetail>
            <LineItemNum>
              <BuyerLineItemNum>30</BuyerLineItemNum>
            </LineItemNum>
            <ItemIdentifiers>
              <PartNumbers>
                <BuyerPartNumber>
                  <PartNum>
                    <PartID>IdBuyer</PartID>
                  </PartNum>
                </BuyerPartNumber>
                <SellerPartNumber>
                  <PartNum>
                    <PartID>EAN13</PartID>
                  </PartNum>
                </SellerPartNumber>
              </PartNumbers>
            </ItemIdentifiers>
            <TotalQuantity>
              <Quantity>
                <QuantityValue>2</QuantityValue>
                <UnitOfMeasurement>
                  <UOMCoded>EA</UOMCoded>
                </UnitOfMeasurement>
              </Quantity>
            </TotalQuantity>
          </BaseItemDetail>
          <PricingDetail>
            <ListOfPrice>
              <Price>
                <UnitPrice>
                  <Currency>
                    <CurrencyCoded>CHF</CurrencyCoded>
                  </Currency>
                  <UnitPriceValue>1.00</UnitPriceValue>
                </UnitPrice>
              </Price>
            </ListOfPrice>
            <TotalValue>
              <MonetaryValue>
                <MonetaryAmount>2.00</MonetaryAmount>
              </MonetaryValue>
            </TotalValue>
          </PricingDetail>
          <DeliveryDetail>
            <ListOfScheduleLine>
              <ScheduleLine>
                <RequestedDeliveryDate>20040630</RequestedDeliveryDate>
              </ScheduleLine>
            </ListOfScheduleLine>
          </DeliveryDetail>
        </OrderResponseItemDetail>
      </ListOfOrderResponseItemDetail>
    </OrderResponseDetail>
  </OrderResponse>

        EOS
				assert_equal(expected, xml.to_s(1))
			end
			def test_i2_xml_invoice
				src = <<-EOS
"00" "Plica" "Electro LAN SA" "20060522" "2300" "INVOIC" "0"
"01" "000" "00332720" "20060522" "PLVH-122545" "B-678033 N, 22.5.06" "OC" "TP"
"02" "SE" "PLICA AG" "" "ZUERCHERSTRASSE 350" "FRAUENFELD" "8500" "CH"
"02" "CU" "ELECTRO LAN SA" "ARTICLE ELECTRIQUE EN GROS" "RUE DE TUNNEL 67-69" "NEUCHÂTEL" "2000" "CH"
"02" "EP" "GIOVANNI RUSSO" "" "" "" "" ""
"02" "BY" "ELECTRO LAN SA" "ARTICLE ELECTRIQUE EN GROS" "RUE DE TUNNEL 67-69" "NEUCHÂTEL" "2000" "CH"
"02" "DP" "ELECTRO LAN SA" "ARTICLE ELECTRIQUE EN GROS" "RUE DE TUNNEL 67-69" "NEUCHÂTEL" "2000" "CH"
"10" "10" "" "125.954.300" "1" "86" "86" "25.8" "25.8" "0" "0" "60.2" "60.2" "" ""
"10" "20" "" "126.276.030" "30" "268" "80.4" "0" "0" "0" "0" "268" "80.4" "" ""
"90" "140.6" "7.61" "10.7" "151.3" "10 Tage 3%, 30 Tage 2%, 60 Tage netto"
				EOS
				ast = Conversion::I2Bdd.parse(src)
				bdd = Conversion::I2Bdd.convert(ast)
				conversion = Conversion::BddGeh.convert(bdd)
				assert_instance_of(Array, conversion)
				assert_equal(1, conversion.size)
        xml = conversion.first
				assert_instance_of(REXML::Document, xml)
        expected = <<-EOS
  <?xml version='1.0' encoding='UTF-8'?>

  <Invoice>
    <InvoiceHeader>
      <InvoiceNumber>
        <Reference>
          <RefNum>00332720</RefNum>
        </Reference>
      </InvoiceNumber>
      <InvoiceIssueDate>20060522000000</InvoiceIssueDate>
      <InvoiceReferences>
        <PurchaseOrderReference>
          <PurchaseOrderNumber>
            <Reference>
              <RefNum>PLVH-122545</RefNum>
            </Reference>
          </PurchaseOrderNumber>
        </PurchaseOrderReference>
      </InvoiceReferences>
      <SellerParty>
        <Party>
          <NameAddress>
            <Name1>PLICA AG</Name1>
            <Street>ZUERCHERSTRASSE 350</Street>
            <PostalCode>8500</PostalCode>
            <City>FRAUENFELD</City>
          </NameAddress>
        </Party>
      </SellerParty>
    </InvoiceHeader>
    <InvoiceDetail>
      <ListOfInvoiceItemDetail>
        <InvoiceItemDetail>
          <InvoiceBaseItemDetail>
            <LineItemNum>
              <BuyerLineItemNum>10</BuyerLineItemNum>
            </LineItemNum>
            <ItemIdentifiers>
              <PartNumbers>
                <BuyerPartNumber>
                  <PartNum>
                    <PartID>125.954.300</PartID>
                  </PartNum>
                </BuyerPartNumber>
              </PartNumbers>
            </ItemIdentifiers>
            <TotalQuantity>
              <Quantity>
                <QuantityValue>1</QuantityValue>
                <UnitOfMeasurement>
                  <UOMCoded>EA</UOMCoded>
                </UnitOfMeasurement>
              </Quantity>
            </TotalQuantity>
          </InvoiceBaseItemDetail>
          <InvoicePricingDetail>
            <ListOfPrice>
              <Price>
                <UnitPrice>
                  <Currency>
                    <CurrencyCoded>CHF</CurrencyCoded>
                  </Currency>
                  <UnitPriceValue>86.00</UnitPriceValue>
                </UnitPrice>
              </Price>
            </ListOfPrice>
            <InvoiceCurrencyTotalValue>
              <MonetaryValue>
                <MonetaryAmount>86.00</MonetaryAmount>
              </MonetaryValue>
            </InvoiceCurrencyTotalValue>
          </InvoicePricingDetail>
        </InvoiceItemDetail>
        <InvoiceItemDetail>
          <InvoiceBaseItemDetail>
            <LineItemNum>
              <BuyerLineItemNum>20</BuyerLineItemNum>
            </LineItemNum>
            <ItemIdentifiers>
              <PartNumbers>
                <BuyerPartNumber>
                  <PartNum>
                    <PartID>126.276.030</PartID>
                  </PartNum>
                </BuyerPartNumber>
              </PartNumbers>
            </ItemIdentifiers>
            <TotalQuantity>
              <Quantity>
                <QuantityValue>30</QuantityValue>
                <UnitOfMeasurement>
                  <UOMCoded>EA</UOMCoded>
                </UnitOfMeasurement>
              </Quantity>
            </TotalQuantity>
          </InvoiceBaseItemDetail>
          <InvoicePricingDetail>
            <ListOfPrice>
              <Price>
                <UnitPrice>
                  <Currency>
                    <CurrencyCoded>CHF</CurrencyCoded>
                  </Currency>
                  <UnitPriceValue>268.00</UnitPriceValue>
                </UnitPrice>
              </Price>
            </ListOfPrice>
            <InvoiceCurrencyTotalValue>
              <MonetaryValue>
                <MonetaryAmount>80.40</MonetaryAmount>
              </MonetaryValue>
            </InvoiceCurrencyTotalValue>
          </InvoicePricingDetail>
        </InvoiceItemDetail>
      </ListOfInvoiceItemDetail>
    </InvoiceDetail>
    <InvoiceSummary>
      <NumberOfLines>2</NumberOfLines>
      <InvoiceTotals>
        <NetValue>
          <MonetaryValue>
            <MonetaryAmount>140.60</MonetaryAmount>
          </MonetaryValue>
        </NetValue>
        <TotalTax>
          <MonetaryValue>
            <MonetaryAmount>10.70</MonetaryAmount>
          </MonetaryValue>
        </TotalTax>
        <TotalAmountPlusTax>
          <MonetaryValue>
            <MonetaryAmount>151.30</MonetaryAmount>
          </MonetaryValue>
        </TotalAmountPlusTax>
      </InvoiceTotals>
    </InvoiceSummary>
  </Invoice>

        EOS
				assert_equal(expected, xml.to_s(1))
			end
		end
	end
end
