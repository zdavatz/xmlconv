#!/usr/bin/env ruby
# TestGehBdd -- xmlconv2 -- 17.05.2006 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/geh_bdd'
require 'date'

module XmlConv
	module Conversion
		class TestGehBdd < Test::Unit::TestCase
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
						<City>Kloten</City>
						<PostalCode>8302</PostalCode>
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
			def test_convert
				bdd = GehBdd.convert(@xml_doc)
				assert_instance_of(Model::Bdd, bdd)
				bsr = bdd.bsr
				assert_instance_of(Model::Bsr, bsr)
				delivery = bdd.deliveries.first
				assert_instance_of(Model::Delivery, delivery)
				assert_equal(bsr, delivery.bsr)
			end
			def test_parse
				document = GehBdd.parse(@src)
				assert_instance_of(REXML::Document, document)
			end
			def test__bdd_add_xml_delivery
				bdd = Model::Bdd.new
				GehBdd._bdd_add_xml_delivery(bdd, @xml_doc)
				delivery = bdd.deliveries.first
				assert_instance_of(Model::Delivery, delivery)		
				assert_equal('B-999999', delivery.customer_id)
				seller = delivery.seller
				assert_instance_of(Model::Party, seller)
				customer = delivery.customer	
				assert_instance_of(Model::Party, customer)
				items = delivery.items
				assert_equal(2, items.size)
				item1 = items.first
				assert_instance_of(Model::DeliveryItem, item1)
				assert_equal('10', item1.line_no)
				assert_equal('123123123', item1.et_nummer_id)
				assert_equal('3', item1.qty)
				assert_equal(Date.new(2006,5,16), item1.delivery_date)
				item2 = items.last
				assert_instance_of(Model::DeliveryItem, item2)
				assert_equal('20', item2.line_no)
				assert_equal('234236837482', item2.et_nummer_id)
				assert_equal('10', item2.qty)
				assert_equal(Date.new(2006,5,16), item2.delivery_date)
			end
			def test__bdd_add_xml_header
				header = REXML::XPath.first(@xml_doc, '//OrderRequestHeader')
				bdd = Model::Bdd.new
				GehBdd._bdd_add_xml_header(bdd, header)
				bsr = bdd.bsr
				assert_instance_of(Model::Bsr, bsr)
				buyer = bsr.parties.first
				assert_instance_of(Model::Party, buyer)
				assert_equal('123456', buyer.acc_id)
			end
			def test__container_add_xml_party__buyer
				xml_party = REXML::XPath.first(@xml_doc, "//BuyerParty/Party")
				delivery = Model::Delivery.new
				GehBdd._container_add_xml_party(delivery, xml_party, 'Customer')
				customer = delivery.customer
				assert_instance_of(Model::Party, customer)
				assert_equal('Grossauer Elektro - Handels AG', customer.name.to_s)
        assert_equal('123456', customer.acc_id)
				cust_addr = customer.address
				assert_instance_of(Model::Address, cust_addr)
				assert_equal(['Thalerstrasse 1'], cust_addr.lines)
				assert_equal('Heiden', cust_addr.city)
				assert_equal('9410', cust_addr.zip_code)
				employee = customer.employee
				assert_instance_of(Model::Party, employee)
				assert_instance_of(Model::Name, employee.name)
				assert_equal('Danilo Lanzafame', employee.name.last)
				assert_equal('Danilo Lanzafame', employee.name.to_s)
			end
			def test__container_add_xml_party__seller
				xml_party = REXML::XPath.first(@xml_doc, "//SellerParty/Party")
				delivery = Model::Delivery.new
				GehBdd._container_add_xml_party(delivery, xml_party, 'Seller')
				seller = delivery.seller
				assert_equal('Test AG', seller.name.to_s)
				assert_instance_of(Model::Party, seller)
				cust_addr = seller.address
				assert_instance_of(Model::Address, cust_addr)
				assert_equal(['Brunnengasse 3'], cust_addr.lines)
				assert_equal('Kloten', cust_addr.city)
				assert_equal('8302', cust_addr.zip_code)
			end
			def test__delivery_add_xml_header
				header = REXML::XPath.first(@xml_doc, '//OrderRequestHeader')
				delivery = Model::Delivery.new
				GehBdd._delivery_add_xml_header(delivery, header)
				assert_equal('B-999999', delivery.customer_id)
				ship_to = delivery.customer.ship_to
				assert_instance_of(Model::Party, ship_to)
				assert_equal('GROSSAUER Elektro-Handels AG', ship_to.name.to_s)
				assert_instance_of(Model::Party, ship_to)
				ship_addr = ship_to.address
				assert_instance_of(Model::Address, ship_addr)
				assert_equal(['Thalerstrasse 1'], ship_addr.lines)
				assert_equal('Heiden', ship_addr.city)
				assert_equal('9410', ship_addr.zip_code)
			end
			def test__delivery_add_xml_item
				xml_item = REXML::XPath.first(@xml_doc, '//ItemDetail')
				delivery = Model::Delivery.new
				GehBdd._delivery_add_xml_item(delivery, xml_item)
				item = delivery.items.first
				assert_instance_of(Model::DeliveryItem, item)
				assert_equal('10', item.line_no)
				assert_equal('123123123', item.et_nummer_id)
				assert_equal('123 890 390', item.ids['LIEFERANTENARTIKEL'])
				assert_equal('3', item.qty)
				assert_equal(Date.new(2006, 5, 16), item.delivery_date)
        price = item.get_price('NettoPreis')
        assert_instance_of(Model::Price, price)
				assert_equal('780.00', price.amount)
			end
		end
	end
end
