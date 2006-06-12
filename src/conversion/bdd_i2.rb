#!/usr/bin/env ruby
# BddI2 -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'i2/document'
require 'i2/address'
require 'i2/position'

module XmlConv
	module Conversion
		class BddI2
			I2_ADDR_CODES = {
				'BillTo'		=>	:buyer,
				'Employee'	=>	:employee,
				'ShipTo'		=>	:delivery,
			}
			class << self
				def convert(bdd)
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
					customer.parties.each { |party|
						_order_add_party(order, party)
					}
				end
				def _order_add_party(order, party)
					address = I2::Address.new
					address.party_id = party.acc_id
					if(name = party.name)
						address.name1 = name.to_s
					end
					if(code = I2_ADDR_CODES[party.role])
						address.code = code
					end
					if(bdd_addr = party.address)
						_address_add_bdd_addr(address, bdd_addr)
					end
					order.add_address(address)
				end
				def _order_add_item(order, item)
					position = I2::Position.new
					position.number = item.line_no
					position.article_ean = item.et_nummer_id
          if(id = item.customer_id)
            position.customer_id = id
          end
					position.qty = item.qty
					if(date = item.delivery_date)
						position.delivery_date = I2::Date.from_date(date)
					end
          if(price = item.get_price('NettoPreis'))
            position.price = price.amount
          end
					order.add_position(position)
				end
			end
		end
	end
end
