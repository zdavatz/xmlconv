#!/usr/bin/env ruby
# BddXml -- xmlconv2 -- 21.06.2004 -- hwyss@ywesee.com

require 'rexml/document'

module XmlConv
	module Conversion
		class BddXml
			class << self
				def convert(bdd)
					skeleton = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE BDD SYSTEM "ABB BDD.dtd">
<BDD />
					EOS
					doc = REXML::Document.new(skeleton)
					_xml_add_bdd_bsr(doc.root, bdd.bsr)
					bdd.deliveries.each { |delivery|
						_xml_add_bdd_delivery(doc.root, delivery)
					}
					doc
				end
				def _xml_add_bdd_address(xml_elm, address)
					xml_addr = REXML::Element.new('Address')
					address.lines.each { |line|
						xml_line = REXML::Element.new('AddressLine')
						xml_line.text = line
						xml_addr.add_element(xml_line)
					}
					if(city = address.city)
						xml_city = REXML::Element.new('City')
						xml_city.text = city
						xml_addr.add_element(xml_city)
					end
					if(zip_code = address.zip_code)
						xml_zip = REXML::Element.new('ZipCode')
						xml_zip.add_attribute('Domain', 'CH')
						xml_zip.text = zip_code
						xml_addr.add_element(xml_zip)
					end
					xml_elm.add_element(xml_addr)
				end
				def _xml_add_bdd_bsr(xml_bdd, bsr)
					xml_bsr = REXML::Element.new('BSR')
					timestamp = REXML::Element.new('Timestamp')
					time = Time.now
					zone = sprintf("%+i", time.gmtoff / 3600)
					timestamp.add_attribute('Zone', zone)
					timestamp.text = time.strftime('%Y%m%d%H%M%S')
					xml_bsr.add_element(timestamp)
					verb = REXML::Element.new('Verb')
					verb.text = 'Return'	
					xml_bsr.add_element(verb)
					noun = REXML::Element.new('Noun')
					noun.text = 'Status'
					xml_bsr.add_element(noun)
					bsr.parties.each { |party|
						_xml_add_bdd_party(xml_bsr, party)
					}
					xml_bdd.add_element(xml_bsr)
				end
				def _xml_add_bdd_delivery(xml_bdd, delivery)
					xml_delivery = REXML::Element.new('Delivery')
					delivery.ids.each { |domain, id|
						_xml_add_domain_id(xml_delivery, domain, id, 'DeliveryId')
					}
					delivery.parties.each { |party|
						_xml_add_bdd_party(xml_delivery, party)
					}
					delivery.items.each { |item|
						_xml_add_delivery_item(xml_delivery, item)
					}
					delivery.prices.each { |price|
						_xml_add_item_price(xml_delivery, price)
					}
					if(agreement = delivery.agreement)
						xml_agreement = REXML::Element.new('Agreement')
						terms = REXML::Element.new('TermsCond')
						terms.text = agreement.terms_cond
						xml_agreement.add_element(terms)
						xml_delivery.add_element(xml_agreement)
					end
					xml_bdd.add_element(xml_delivery)
				end
				def _xml_add_bdd_name(xml_elm, name)
					xml_name = REXML::Element.new('Name')
					if(name.text)
						xml_name.text = name.to_s
					else
						if(first = name.first)
							xml_first = REXML::Element.new('FirstName')
							xml_first.text = first
							xml_name.add_element(xml_first)
						end
						if(last = name.last)
							xml_last = REXML::Element.new('LastName')
							xml_last.text = last
							xml_name.add_element(xml_last)
						end
					end
					xml_elm.add_element(xml_name)
				end
				def _xml_add_bdd_party(xml_elm, party)
					xml_party = REXML::Element.new('Party')
					xml_party.add_attribute('Version', '2')
					xml_party.add_attribute('Role', party.role)
					party.ids.each { |domain, id|
						_xml_add_domain_id(xml_party, domain, id, 'PartyId')
					}
					if(name = party.name)
						_xml_add_bdd_name(xml_party, name)
					end
					if(addr = party.address)
						_xml_add_bdd_address(xml_party, addr)
					end
					party.parties.each { |subdiv|
						_xml_add_bdd_party(xml_party, subdiv)
					}
					xml_elm.add_element(xml_party)
				end
				def _xml_add_delivery_item(xml_delivery, item)
					xml_item = REXML::Element.new('DeliveryItem')
					line_no = REXML::Element.new('LineNo')
					line_no.text = item.line_no
					xml_item.add_element(line_no)
					ids = item.ids
					unless(ids.empty?)
						xml_id = REXML::Element.new('PartId')
						ids.each { |domain, id|
							_xml_add_domain_id(xml_id, domain, id, 'IdentNo')
						}
						xml_item.add_element(xml_id)
					end
					xml_qty = REXML::Element.new('Qty')
					xml_qty.text = item.qty
					xml_item.add_element(xml_qty)
					item.prices.each { |price|
						_xml_add_item_price(xml_item, price)
					}
					item.free_texts.each { |freetext|
						_xml_add_freetext(xml_item, freetext)
					}
					xml_delivery.add_element(xml_item)
				end
				def _xml_add_domain_id(xml_elm, domain, idstr, idname)
					xml_id = REXML::Element.new(idname)
					xml_id.add_attribute('Domain', domain)
					xml_id.text = idstr
					xml_elm.add_element(xml_id)
				end
				def _xml_add_freetext(xml_elm, freetext)
					xml_text = REXML::Element.new('FreeText')
					xml_text.add_attribute('Type', freetext.type)
					xml_text.text = freetext.to_s
					xml_elm.add_element(xml_text)
				end
				def _xml_add_item_price(xml_item, price)
					xml_price = REXML::Element.new('Price')
					xml_price.add_attribute('Purpose', price.purpose)
					xml_price.text = sprintf('%2.2f', price.amount / 100.0)
					xml_item.add_element(xml_price)
				end
			end
		end
	end
end
