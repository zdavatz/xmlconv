#!/usr/bin/env ruby
# Integration::TestGehI2 -- xmlconv2 -- 23.05.2006 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/geh_bdd'
require 'conversion/bdd_i2'
require 'mock'

module XmlConv
	module Integration
		class TestGehI2 < Test::Unit::TestCase
			def setup
				@src = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<OrderRequest>
	<OrderRequestHeader>
		<OrderRequestNumber>
			<BuyerOrderRequestNumber>B-999999</BuyerOrderRequestNumber>
		</OrderRequestNumber>
		<OrderRequestIssueDate>20060511T13:30:35</OrderRequestIssueDate>
		<Purpose>
			<PurposeCoded>InformationOnly</PurposeCoded>
		</Purpose>
		<RequestedResponse>
			<RequestedResponseCoded>NoAcknowledgementNeeded</RequestedResponseCoded>
		</RequestedResponse>
		<OrderRequestCurrency>
			<Currency>
				<CurrencyCoded>CHF</CurrencyCoded>
			</Currency>
		</OrderRequestCurrency>
		<OrderRequestLanguage>
			<Language>
				<LanguageCoded>ge</LanguageCoded>
			</Language>
		</OrderRequestLanguage>
		<OrderRequestParty>
			<BuyerParty>
				<Party>
					<PartyID>
						<Identifier>
							<Ident>123456</Ident>
						</Identifier>
					</PartyID>
					<NameAddress>
						<Name1>Grossauer Elektro - Handels AG</Name1>
						<Name2></Name2>
						<Street>Thalerstrasse 1</Street>
						<City>Heiden</City>
						<PostalCode>9410</PostalCode>
					</NameAddress>
					<OrderContact>
						<Contact>
							<ContactName>Danilo Lanzafame</ContactName>
						</Contact>
					</OrderContact>
				</Party>
			</BuyerParty>
			<SellerParty>
				<Party>
					<NameAddress>
						<Name1>Test AG</Name1>
						<Name2>TestName2</Name2>
						<Street>Brunnengasse 3</Street>
						<City>8302</City>
						<PostalCode>Kloten</PostalCode>
					</NameAddress>
				</Party>
			</SellerParty>
		</OrderRequestParty>
		<OrderTermsOfDelivery>
			<TermsOfDelivery>
				<TermsOfDeliveryFunctionCoded>Other</TermsOfDeliveryFunctionCoded>
				<TermsOfDeliveryFunctionCodedOther>V2</TermsOfDeliveryFunctionCodedOther>
				<TransportTermsCoded>Other</TransportTermsCoded>
				<TransportTermsCodedOther>Auto EK</TransportTermsCodedOther>
				<ShipmentMethodOfPaymentCoded>Other</ShipmentMethodOfPaymentCoded>
				<ShipmentMethodOfPaymentCodedOther>Franko Domizil</ShipmentMethodOfPaymentCodedOther>
				<Location>
					<NameAddress>
						<Name1>GROSSAUER Elektro-Handels AG</Name1>
						<Name2>
						</Name2>
						<Street>Thalerstrasse 1</Street>
						<City>Heiden</City>
						<PostalCode>9410</PostalCode>
					</NameAddress>
				</Location>
			</TermsOfDelivery>
		</OrderTermsOfDelivery>
	</OrderRequestHeader>
	<OrderRequestDetail>
		<OrderDetail>
			<ListOfItemDetail>
				<ItemDetail>
					<BaseItemDetail>
						<LineItemNum>
							<BuyerLineItemNum>10</BuyerLineItemNum>
						</LineItemNum>
						<ItemIdentifiers>
							<PartNumbers>
								<SellerPartNumber>
									<PartNum>
										<SellerPartNumberPartID>123123123</SellerPartNumberPartID>
									</PartNum>
								</SellerPartNumber>
								<BuyerPartNumber>
									<PartNum>
										<BuyerPartNumberPartID>123 890 390</BuyerPartNumberPartID>
									</PartNum>
								</BuyerPartNumber>
							</PartNumbers>
							<CommodityCode>
								<Identifier>
									<Agency>
										<AgencyCoded>EAN</AgencyCoded>
									</Agency>
								</Identifier>
							</CommodityCode>
						</ItemIdentifiers>
						<TotalQuantity>
							<Quantity>
								<QuantityValue>3</QuantityValue>
								<UnitOfMeasurement>
									<UOMCoded>Other</UOMCoded>
									<UOMCodedOther>Other</UOMCodedOther>
								</UnitOfMeasurement>
							</Quantity>
						</TotalQuantity>
					</BaseItemDetail>
					<PricingDetail>
						<ListOfPrice>
							<Price>
								<UnitPrice>
									<UnitPriceValue>780.00</UnitPriceValue>
									<Currency>
										<CurrencyCoded>CHF</CurrencyCoded>
									</Currency>
								</UnitPrice>
								<PriceBasisQuantity>
									<Quantity>
										<UnitOfMeasurement>
											<UOMCoded>100</UOMCoded>
										</UnitOfMeasurement>
									</Quantity>
								</PriceBasisQuantity>
								<PriceMultiplier>
									<PriceMultiplierCoded>DiscountMultiplier</PriceMultiplierCoded>
									<Multiplier>.68</Multiplier>
								</PriceMultiplier>
							</Price>
						</ListOfPrice>
						<Tax>
							<TaxFunctionQualifierCoded>Tax</TaxFunctionQualifierCoded>
							<TaxAmount>1.17</TaxAmount>
						</Tax>
					</PricingDetail>
					<DeliveryDetail>
						<ListOfScheduleLine>
							<ScheduleLine>
								<Quantity>
									<QuantityValue>3</QuantityValue>
									<UnitOfMeasurement>
										<UOMCoded>STK</UOMCoded>
									</UnitOfMeasurement>
								</Quantity>
								<RequestedDeliveryDate>20060516T13:30:35</RequestedDeliveryDate>
							</ScheduleLine>
						</ListOfScheduleLine>
					</DeliveryDetail>
					<LineItemNote></LineItemNote>
				</ItemDetail>
				<ItemDetail>
					<BaseItemDetail>
						<LineItemNum>
							<BuyerLineItemNum>20</BuyerLineItemNum>
						</LineItemNum>
						<ItemIdentifiers>
							<PartNumbers>
								<SellerPartNumber>
									<PartNum>
										<SellerPartNumberPartID>234236837482</SellerPartNumberPartID>
									</PartNum>
								</SellerPartNumber>
								<BuyerPartNumber>
									<PartNum>
										<BuyerPartNumberPartID>283 222 011</BuyerPartNumberPartID>
									</PartNum>
								</BuyerPartNumber>
							</PartNumbers>
							<CommodityCode>
								<Identifier>
									<Agency>
										<AgencyCoded>EAN</AgencyCoded>
									</Agency>
								</Identifier>
							</CommodityCode>
						</ItemIdentifiers>
						<TotalQuantity>
							<Quantity>
								<QuantityValue>10</QuantityValue>
								<UnitOfMeasurement>
									<UOMCoded>Other</UOMCoded>
									<UOMCodedOther>Other</UOMCodedOther>
								</UnitOfMeasurement>
							</Quantity>
						</TotalQuantity>
					</BaseItemDetail>
					<PricingDetail>
						<ListOfPrice>
							<Price>
								<UnitPrice>
									<UnitPriceValue>330.00</UnitPriceValue>
									<Currency>
										<CurrencyCoded>CHF</CurrencyCoded>
									</Currency>
								</UnitPrice>
								<PriceBasisQuantity>
									<Quantity>
										<UnitOfMeasurement>
											<UOMCoded>100</UOMCoded>
										</UnitOfMeasurement>
									</Quantity>
								</PriceBasisQuantity>
								<PriceMultiplier>
									<PriceMultiplierCoded>DiscountMultiplier</PriceMultiplierCoded>
									<Multiplier>.68</Multiplier>
								</PriceMultiplier>
							</Price>
						</ListOfPrice>
						<Tax>
							<TaxFunctionQualifierCoded>Tax</TaxFunctionQualifierCoded>
							<TaxAmount>1.71</TaxAmount>
						</Tax>
					</PricingDetail>
					<DeliveryDetail>
						<ListOfScheduleLine>
							<ScheduleLine>
								<Quantity>
									<QuantityValue>10</QuantityValue>
									<UnitOfMeasurement>
										<UOMCoded>STK</UOMCoded>
									</UnitOfMeasurement>
								</Quantity>
								<RequestedDeliveryDate>20060516T13:30:35</RequestedDeliveryDate>
							</ScheduleLine>
						</ListOfScheduleLine>
					</DeliveryDetail>
					<LineItemNote></LineItemNote>
				</ItemDetail>
			</ListOfItemDetail>
		</OrderDetail>
	</OrderRequestDetail>
</OrderRequest>
				EOS
				@xml_doc = REXML::Document.new(@src)
			end
			def test_geh_i2
				bdd = Conversion::GehBdd.convert(@xml_doc)
				i2_doc = Conversion::BddI2.convert(bdd)
				result = i2_doc.to_s.split("\n")
				expected = <<-EOS
001:EPIN_PL
002:ORDERX
003:220
010:#{i2_doc.filename}
100:123456
101:B-999999
201:EP
220:Danilo Lanzafame
201:BY
220:Grossauer Elektro - Handels AG
222:Thalerstrasse 1
223:Heiden
225:9410
201:DP
220:GROSSAUER Elektro-Handels AG
222:Thalerstrasse 1
223:Heiden
225:9410
237:61
300:4
301:#{Date.today.strftime('%Y%m%d')}
500:10
501:123123123
520:3
540:2
541:20060516
500:20
501:234236837482
520:10
540:2
541:20060516
				EOS
				expected.split("\n").each_with_index { |line, index|
					assert_equal(line, result[index])
				}
			end
		end
	end
end
