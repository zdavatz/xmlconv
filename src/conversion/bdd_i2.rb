#!/usr/bin/env ruby
# BddI2 -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'i2/document'
require 'i2/address'
require 'i2/position'

module XmlConv
	module Conversion
		class BddI2
			class << self
				def bdd2i2(bdd)
					doc = I2::Document.new
					header = I2::Header.new
					doc.header = header
					bdd.deliveries.each { |delivery|
						_doc_add_delivery(doc, delivery)
					}
					doc
				end
				def _doc_add_delivery(doc, delivery)
					order = I2::Order.new
					order.sender_id = delivery.bsr_id
					# customer_id is in reality the delivery_id assigned by the
					# customer - the slight confusion is due to automatic naming
					order.delivery_id = delivery.customer_id 
					order.add_date(I2::Date.from_date(::Date.today))
					if(customer = delivery.customer)
						_order_add_customer(order, customer)
					end
					delivery.items.each { |item|
						_order_add_item(order, item)
					}
					doc.add_order(order)
				end
				def _address_add_bdd_addr(address, bdd_addr)
					if(bdd_addr.size < 2)
						bdd_addr.lines.each_with_index { |line, idx|
							address.send("street#{idx.next}=", line)
						}
					else
						ln1, ln2, ln3 = bdd_addr.lines
						address.name2 = ln1
						address.street1 = ln2
						address.street2 = ln3 unless(ln3.nil?)
					end
					address.city = bdd_addr.city
					address.zip_code = bdd_addr.zip_code
				end
				def _order_add_customer(order, customer)
					if((bill_to = customer.bill_to) && (acc_id = bill_to.acc_id))
						address = I2::Address.new
						address.buyer_id = acc_id
						order.add_address(address)
					end
					if((ship_to = customer.ship_to) && (bdd_addr = ship_to.address))
						address = I2::Address.new
						address.code = :delivery
						address.name1 = ship_to.name.to_s
						_address_add_bdd_addr(address, bdd_addr)
						order.add_address(address)
					end
				end
				def _order_add_item(order, item)
					position = I2::Position.new
					position.number = item.line_no
					position.article_ean = item.et_nummer_id
					position.qty = item.qty
					if(date = item.delivery_date)
						position.delivery_date = I2::Date.from_date(date)
					end
					order.add_position(position)
				end
			end
		end
	end
end
