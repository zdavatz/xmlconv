#!/usr/bin/env ruby
# GehBdd -- xmlconv2 -- 17.05.2006 -- hwyss@ywesee.com

require 'rexml/document'
require 'model/address'
require 'model/bdd'
require 'model/bsr'
require 'model/delivery'
require 'model/delivery_item'
require 'model/name'
require 'model/party'

module XmlConv
	module Conversion
		class GehBdd
class << self
	def convert(xml_document)
		bdd = Model::Bdd.new
		_bdd_add_xml_delivery(bdd, xml_document)
		bdd
	end
	def parse(xml_src)
		REXML::Document.new(xml_src)
	end
	def _bdd_add_xml_delivery(bdd, xml_document)
		delivery = Model::Delivery.new
		xml_header = REXML::XPath.first(xml_document, 
			'OrderRequest/OrderRequestHeader')
		_bdd_add_xml_header(bdd, xml_header)
		_delivery_add_xml_header(delivery, xml_header)
		REXML::XPath.each(xml_document, 'OrderRequest//ItemDetail') { |xml_item|
			_delivery_add_xml_item(delivery, xml_item)	
		}
		delivery.bsr = bdd.bsr
		bdd.add_delivery(delivery)
		delivery
	end
	def _bdd_add_xml_header(bdd, xml_header)
		bsr = Model::Bsr.new
		xml_party = REXML::XPath.first(xml_header, '//BuyerParty/Party')
		if(xml_id = REXML::XPath.first(xml_party, '//PartyID/Identifier/Ident'))
			party = Model::Party.new
			# ACC: ABB-Customer Domain
			party.role = 'Customer'
			party.add_id('ACC', _latin1(xml_id.text))
			bsr.add_party(party)
		end
		bdd.bsr = bsr
	end
	def _container_add_xml_id(container, xml_id, domain)
		domain = _latin1(xml_id.attribute('Domain').value)
		value = _latin1(xml_id.text)
		container.add_id(domain, value)
	end
	def _container_add_xml_party(container, xml_party, role)
		party = Model::Party.new
		party.role = role
		if(xml_address = REXML::XPath.first(xml_party, 'NameAddress'))
			_party_add_xml_address(party, xml_address)
			if(xml_name = REXML::XPath.first(xml_address, 'Name1'))
				_party_add_xml_name(party, xml_name)
			end
		end
		if(xml_name = REXML::XPath.first(xml_party, 'OrderContact//ContactName'))
			employee = Model::Party.new
			employee.role = 'Employee'
			_party_add_xml_name(employee, xml_name)
			party.add_party(employee)
		end
		container.add_party(party)
    party
	end
	def _delivery_add_xml_header(delivery, xml_header)
		xml_id = REXML::XPath.first(xml_header, 
												'OrderRequestNumber/BuyerOrderRequestNumber')
		delivery.add_id('Customer', _latin1(xml_id.text))
		xml_buyer = REXML::XPath.first(xml_header, 
																	 'OrderRequestParty//BuyerParty/Party')
		customer = _container_add_xml_party(delivery, xml_buyer, 'Customer')
    _container_add_xml_party(customer, xml_buyer, 'BillTo')
		if(xml_location = REXML::XPath.first(xml_header, 
												 'OrderTermsOfDelivery//TermsOfDelivery/Location'))
			_container_add_xml_party(customer, xml_location, 'ShipTo')
		end
		xml_seller = REXML::XPath.first(xml_header, 
																		'OrderRequestParty//SellerParty/Party')
		_container_add_xml_party(delivery, xml_seller, 'Seller')
	end
	def _delivery_add_xml_item(delivery, xml_item)
		item = Model::DeliveryItem.new
		xml_line_no = REXML::XPath.first(xml_item, 
																		'BaseItemDetail//LineItemNum/*ItemNum')
		item.line_no = _latin1(xml_line_no.text)
=begin # I'm not sure which Id is which..
		if(xml_id = REXML::XPath.first(xml_item, 'BaseItemDetail//AgencyCoded'))
			item.add_id('ET-NUMMER', _latin1(xml_id.text))
		end
=end
		if(xml_id = REXML::XPath.first(xml_item, 
																	 'BaseItemDetail//SellerPartNumberPartID'))
			#item.add_id('Seller', _latin1(xml_id.text))
			item.add_id('ET-NUMMER', _latin1(xml_id.text))
		end
		if(xml_id = REXML::XPath.first(xml_item, 
																	 'BaseItemDetail//BuyerPartNumberPartID'))
			item.add_id('Customer', _latin1(xml_id.text))
		end
		xml_qty = REXML::XPath.first(xml_item, 'BaseItemDetail//QuantityValue')
		item.qty = xml_qty.text.to_i
		if(xml_date = REXML::XPath.first(xml_item, 
																	   'DeliveryDetail//RequestedDeliveryDate'))
			raw = _latin1(xml_date.text)
			item.delivery_date = begin
														 Date.parse(raw)
													 rescue
														 Date.today
													 end
		end
		delivery.add_item(item)
	end
	def _latin1(str)
		Iconv.iconv('ISO-8859-1', 'UTF8', str).first.strip
	rescue
		str
	end
	def _party_add_xml_address(party, xml_address)
		address = Model::Address.new
		REXML::XPath.each(xml_address, 'Street') { |xml_addr_line|
			address.add_line(_latin1(xml_addr_line.text))
		}
		xml_city = REXML::XPath.first(xml_address, 'City')
		address.city = _latin1(xml_city.text)
		xml_zip_code = REXML::XPath.first(xml_address, 'PostalCode')
		address.zip_code = _latin1(xml_zip_code.text)
		party.address = address
	end
	def _party_add_xml_name(party, xml_name)
		name = Model::Name.new
		name.last = _latin1(xml_name.text)
		party.name = name
	end
end
		end
	end
end
