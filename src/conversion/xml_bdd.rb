#!/usr/bin/env ruby
# XmlBdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'date'
require 'rexml/document'
require 'rexml/xpath'
require 'model/address'
require 'model/bdd'
require 'model/bsr'
require 'model/delivery'
require 'model/delivery_item'
require 'model/name'
require 'model/party'

module XmlConv
	module Conversion
		class XmlBdd
			class << self
				def convert(xml_document)
					bdd = Model::Bdd.new
					if(xml_bsr = REXML::XPath.first(xml_document, 'BDD/BSR'))
						_bdd_add_xml_bsr(bdd, xml_bsr)
					end
					REXML::XPath.each(xml_document, 'BDD/Delivery') { |xml_delivery|
						_bdd_add_xml_delivery(bdd, xml_delivery)
					}
					bdd
				end
				def parse(xml_src)
					REXML::Document.new(xml_src)
				end
				def _bdd_add_xml_bsr(bdd, xml_bsr)
					bsr = Model::Bsr.new
					REXML::XPath.each(xml_bsr, 'Party') { |xml_party|
						_container_add_xml_party(bsr, xml_party)
					}
					bdd.bsr = bsr
				end
				def _bdd_add_xml_delivery(bdd, xml_delivery)
					delivery = Model::Delivery.new
					delivery.bsr = bdd.bsr
					REXML::XPath.each(xml_delivery, 'DeliveryId') { |xml_id|
						_container_add_xml_id(delivery, xml_id)
					}
					REXML::XPath.each(xml_delivery, 'Party') { |xml_party| 
						_container_add_xml_party(delivery, xml_party)
					}
					REXML::XPath.each(xml_delivery, 'DeliveryItem') { |xml_item|
						_delivery_add_xml_item(delivery, xml_item)	
					}
					bdd.add_delivery(delivery)
				end
				def _container_add_xml_party(container, xml_party)
					party = Model::Party.new
					party.role = _latin1(xml_party.attribute('Role').value)
					REXML::XPath.each(xml_party, 'PartyId') { |xml_id|
						_container_add_xml_id(party, xml_id)
					}
					if(xml_name = REXML::XPath.first(xml_party, 'Name'))
						_party_add_xml_name(party, xml_name)
					end
					if(xml_address = REXML::XPath.first(xml_party, 'Address'))
						_party_add_xml_address(party, xml_address)
					end
					REXML::XPath.each(xml_party, 'Party') { |xml_inner_party|
						_container_add_xml_party(party, xml_inner_party)
					}
					container.add_party(party)
				end
				def _container_add_xml_id(container, xml_id)
					domain = _latin1(xml_id.attribute('Domain').value)
					value = _latin1(xml_id.text)
					container.add_id(domain, value)
				end
				def _delivery_add_xml_item(delivery, xml_item)
					item = Model::DeliveryItem.new
					xml_line_no = REXML::XPath.first(xml_item, 'LineNo')
					item.line_no = _latin1(xml_line_no.text)
					REXML::XPath.each(xml_item, 'PartId/IdentNo') { |xml_id| 
						_container_add_xml_id(item, xml_id)	
					}
					xml_qty = REXML::XPath.first(xml_item, 'Qty')
					item.qty = xml_qty.text.to_i
					if(xml_date = REXML::XPath.first(xml_item, 'DeliveryDate'))
						raw = _latin1(xml_date.text)
						item.delivery_date = begin
							Date.parse(raw.gsub(/\./, '-'))
						rescue
							Date.today
						end
					end
					delivery.add_item(item)
				end
				def _party_add_xml_address(party, xml_address)
					address = Model::Address.new
					REXML::XPath.each(xml_address, 'AddressLine') { |xml_addr_line|
						address.add_line(_latin1(xml_addr_line.text))
					}
					xml_city = REXML::XPath.first(xml_address, 'City')
					address.city = _latin1(xml_city.text)
					xml_zip_code = REXML::XPath.first(xml_address, 'ZipCode')
					address.zip_code = _latin1(xml_zip_code.text)
					party.address = address
				end
				def _party_add_xml_name(party, xml_name)
					name = Model::Name.new
					name.text = _latin1(xml_name.text)
					if(xml_first = REXML::XPath.first(xml_name, 'FirstName'))
						name.first = _latin1(xml_first.text)
					end
					if(xml_last = REXML::XPath.first(xml_name, 'LastName'))
						name.last = _latin1(xml_last.text)
					end
					party.name = name
				end
				def _latin1(str)
					Iconv.iconv('ISO-8859-1', 'UTF8', str).first.strip
				rescue
					str
				end
			end
		end
	end
end
