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
					bdd.invoices.each { |invoice|
						_xml_add_bdd_invoice(doc.root, invoice)
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
						domain = address.country || 'CH'
						xml_zip.add_attribute('Domain', domain)
						xml_zip.text = zip_code
						xml_addr.add_element(xml_zip)
					end
					xml_elm.add_element(xml_addr)
				end
				def _xml_add_bdd_agreement(xml_elm, agreement)
					if(terms_cond = agreement.terms_cond)
						xml_agreement = REXML::Element.new('Agreement')
						terms = REXML::Element.new('TermsCond')
						terms.text = terms_cond
						xml_agreement.add_element(terms)
						xml_elm.add_element(xml_agreement)
					end
				end
				def _xml_add_bdd_bsr(xml_bdd, bsr)
					xml_bsr = REXML::Element.new('BSR')
					timestamp = REXML::Element.new('Timestamp')
					time = bsr.timestamp || Time.now
					zone = sprintf("%+i", time.gmtoff / 3600)
					timestamp.add_attribute('Zone', zone)
					timestamp.text = time.strftime('%Y%m%d%H%M%S')
					xml_bsr.add_element(timestamp)
					verb = REXML::Element.new('Verb')
					verb.text = bsr.verb || 'Return'	
					xml_bsr.add_element(verb)
					noun = REXML::Element.new('Noun')
					noun.text = bsr.noun || 'Status'
					xml_bsr.add_element(noun)
					bsr.parties.each { |party|
						_xml_add_bdd_party(xml_bsr, party)
					}
					xml_bdd.add_element(xml_bsr)
				end
				def _xml_add_bdd_delivery(xml_bdd, delivery)
					xml_delivery = REXML::Element.new('Delivery')
					_xml_assemble_bdd_transaction(xml_delivery, delivery)
					xml_bdd.add_element(xml_delivery)
				end
				def _xml_add_bdd_invoice(xml_bdd, invoice)
					xml_invoice = REXML::Element.new('Invoice')
					if(delivery_id = invoice.delivery_id)
						domain, idstr = delivery_id
						_xml_add_domain_id(xml_invoice, domain, idstr, 'DeliveryId')
					end
					_xml_assemble_bdd_transaction(xml_invoice, invoice)
					xml_bdd.add_element(xml_invoice)
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
					party.ids.each { |domain, idstr|
						_xml_add_domain_id(xml_party, domain, idstr, 'PartyId')
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
					xml_item = _xml_add_item(xml_delivery, item, 'DeliveryItem')
					if((date = item.delivery_date) && date.respond_to?(:strftime))
						xml_date = REXML::Element.new('DeliveryDate')
						xml_date.text = date.strftime('%Y%m%d')
						xml_item.add_element(xml_date)
					end
				end
				def _xml_add_domain_id(xml_elm, domain, idstr, idname)
					xml_id = REXML::Element.new(idname)
					xml_id.add_attribute('Domain', domain)
					xml_id.text = idstr
					xml_elm.add_element(xml_id)
				end
				def _xml_add_free_text(xml_elm, free_text)
					xml_text = REXML::Element.new('FreeText')
					if(type = free_text.type)
						xml_text.add_attribute('Type', type)
					end
					xml_text.text = free_text.to_s
					xml_elm.add_element(xml_text)
				end
				def _xml_add_invoice_item(xml_invoice, item)
					_xml_add_item(xml_invoice, item, 'InvoiceItem')
				end
				def _xml_add_item(xml_elm, item, tag)
					xml_item = REXML::Element.new(tag)
					_xml_add_item_line_no(xml_item, item.line_no)
					_xml_add_item_part_id(xml_item, item)
					xml_qty = REXML::Element.new('Qty')
					xml_qty.text = item.qty
					xml_item.add_element(xml_qty)
					item.prices.each { |price|
						_xml_add_item_price(xml_item, price)
					}
					if(free_text = item.free_text)
						_xml_add_free_text(xml_item, free_text)
					end
					xml_elm.add_element(xml_item)
					xml_item
				end
				def _xml_add_item_line_no(xml_item, line_no)
					if(line_no)
						xml_line_no = REXML::Element.new('LineNo')
						xml_line_no.text = line_no
						xml_item.add_element(xml_line_no)
					end
				end
				def _xml_add_item_part_id(xml_item, item)
					ids = item.ids
					part_infos = item.part_infos
					unless(ids.empty? && part_infos.empty?)
						xml_id = REXML::Element.new('PartId')
						ids.each { |domain, idstr|
							_xml_add_domain_id(xml_id, domain, idstr, 'IdentNo')
						}
						unless(part_infos.empty?)
							xml_info = REXML::Element.new('PartInfo')
							part_infos.each { |part_info|
								xml_value = REXML::Element.new('Value')
								xml_value.add_attribute('Dimension', part_info.dimension)
								xml_value.text = part_info.value
								xml_info.add_element(xml_value)
							}
							xml_id.add_element(xml_info)
						end
						xml_item.add_element(xml_id)
					end
				end
				def _xml_add_item_price(xml_item, price)
					xml_price = REXML::Element.new('Price')
					xml_price.add_attribute('Purpose', price.purpose)
					xml_price.text = sprintf('%2.2f', price.amount / 100.0)
					xml_item.add_element(xml_price)
				end
				def _xml_add_item_status(xml_item, trans)
					status = REXML::Element.new('Status')
					status.text = trans.status
					if((date = trans.status_date) && date.respond_to?(:strftime))
						fmt = "%Y%m%d"
						if(date.is_a?(Time))
							fmt << "%H%M%S"
						end
						status.add_attribute('Date', date.strftime(fmt))
					end
					xml_item.add_element(status)
				end
				def _xml_assemble_bdd_transaction(xml_trans, trans)
					_xml_add_item_status(xml_trans, trans)
					name = xml_trans.name
					trans.ids.each { |domain, idstr|
						_xml_add_domain_id(xml_trans, domain, idstr, name + 'Id')
					}
					trans.parties.each { |party|
						_xml_add_bdd_party(xml_trans, party)
					}
					method = "_xml_add_#{name}_item".downcase
					trans.items.each { |item|
						self.send(method, xml_trans, item)
					}
					trans.prices.each { |price|
						_xml_add_item_price(xml_trans, price)
					}
					if(free_text = trans.free_text)
						_xml_add_free_text(xml_trans, free_text)
					end
					if(agreement = trans.agreement)
						_xml_add_bdd_agreement(xml_trans, agreement)
					end
				end
			end
		end
	end
end
