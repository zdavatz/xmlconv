#!/usr/bin/env ruby
# I2Bdd -- xmlconv2 -- 28.06.2004 -- hwyss@ywesee.com

require 'i2/parser'
require 'model/address'
require 'model/agreement'
require 'model/bdd'
require 'model/bsr'
require 'model/delivery'
require 'model/delivery_item'
require 'model/invoice'
require 'model/invoice_item'
require 'model/name'
require 'model/party'
require 'model/part_info'
require 'model/price'
require 'time'
require 'date'

module XmlConv
	module Conversion
		class I2Bdd
			I2_ADDR_CODES = {
				'BY'	=>	'BillTo',
				'DP'	=>	'ShipTo',
			}
			class << self
				def convert(ast)
					bdd = Model::Bdd.new
					ast.records.each_node { |node|
						_bdd_add_ast_node(bdd, node)
					}
					bdd
				end
				def parse(src)
					I2.cached_parser.parse(src)
				end
				def _bdd_add_address(bdd, address)
					transaction = _select_bdd_transaction(bdd)
					atype = _value(address.atype)
					case(atype)
					when 'SE'
						transaction.seller.address = _bdd_assemble_address(address)
					when 'CU'
						transaction.customer.address = _bdd_assemble_address(address)
					when 'DP', 'BY'
						delivery_party = Model::Party.new
						delivery_party.role = I2_ADDR_CODES[atype]
						delivery_party.address = _bdd_assemble_address(address)
						transaction.customer.add_party(delivery_party)
					when 'EP'
						employee = transaction.customer.employee \
							or _customer_add_employee(customer)
						employee.address = _bdd_assemble_address(address)
					end
				end
				def _bdd_add_ast_node(bdd, node)
					case node.name
					when 'Address'
						_bdd_add_address(bdd, node)
					when 'Commission'
						_bdd_add_commission(bdd, node)
					when 'Header'
						_bdd_add_header(bdd, node)
					when 'HeaderText'
						_bdd_add_header_text(bdd, node)
					when 'Position'
						_bdd_add_position(bdd, node)
					when 'Footer'
						_bdd_add_footer(bdd, node)
					end
				end
				def _bdd_add_commission(bdd, ast)
					if(_bdd_transaction_type(bdd) == 'Invoice')
						_bdd_add_invoice(bdd, ast)
					else
						_bdd_add_delivery(bdd, ast)
					end
				end
				def _bdd_add_delivery(bdd, ast)
					delivery = Model::Delivery.new
					delivery.status = 'Confirmed'
					delivery.add_id('ACC', _value(ast.reference))
					_bdd_assemble_transaction(delivery, ast)
					bdd.add_delivery(delivery)
				end
				def _bdd_add_footer(bdd, ast)
					transaction = _select_bdd_transaction(bdd)
					_item_add_price(transaction, ast.pricenetto, 'SummePositionen')
					_item_add_price(transaction, ast.vatpercent, 'MehrwertsteuerPct')
					_item_add_price(transaction, ast.vatamount, 'Mehrwertsteuer')
					
					_item_add_price(transaction, ast.pricebrutto, 'Endbetrag')
					if(terms = ast.agreement)
						agreement = Model::Agreement.new
						agreement.terms_cond = _value(terms)
						transaction.agreement = agreement
					end
				end
				def _bdd_add_free_text(obj, text, type=nil)
					if(txt = obj.free_text)
						txt << text
					else
						obj.add_free_text(type, text)
					end
				end
				def _bdd_add_header(bdd, ast)
					bsr = Model::Bsr.new
					bsr.timestamp = Time.parse(_value(ast.date).to_s << 
						_value(ast.time).to_s)
					case _value(ast.mtype)
					when 'CONFIRM'
						bsr.verb = 'Return'
						bsr.noun = 'Status'
					when 'INVOICE'
						bsr.verb = 'Return'
						bsr.noun = 'Invoice'
					end
					if(customer_id = _value(ast.sender))
						customer = Model::Party.new
						customer.role = 'Customer'
						customer.add_id('ACC', customer_id)
						bsr.add_party(customer)
					end
					bdd.bsr = bsr
				end
				def _bdd_add_header_text(bdd, ast)
					if(text = _value(ast.text))
						transaction = _select_bdd_transaction(bdd)
						_bdd_add_free_text(transaction, text)
					end
				end
				def _bdd_add_invoice(bdd, ast)
					invoice = Model::Invoice.new
					invoice.status = 'Invoiced'
					invoice.add_delivery_id('ACC', _value(ast.reference))
					_bdd_assemble_transaction(invoice, ast)
					bdd.add_invoice(invoice)
				end
				def _bdd_add_position(bdd, ast)
					transaction = _select_bdd_transaction(bdd)
					if(transaction.is_a?(Model::Invoice))
						_invoice_add_item(transaction, ast)
					else
						_delivery_add_item(transaction, ast)
					end
				end
				def _bdd_assemble_address(address)
					bdd_addr = Model::Address.new
					bdd_addr.add_line(_value(address.name1))
					if(name2 = _value(address.name2))
						bdd_addr.add_line(name2)
					end
					bdd_addr.add_line(_value(address.street))
					bdd_addr.city = _value(address.city)
					bdd_addr.zip_code = _value(address.code)
					bdd_addr.country = _value(address.country)
					bdd_addr
				end
				def _bdd_assemble_item(item, ast)
					item.line_no = _value(ast.lineno)
					if(etnr = _value(ast.eancode))
						item.add_id('ET-Nummer', etnr)
					end
					if(sellercode = _value(ast.sellercode))
						item.add_id('Lieferantenartikel', sellercode)
					end
					if(buyercode = _value(ast.buyercode))
						item.add_id('ACC', buyercode)
					end
					[:description1, :description2].collect { |symbol|
						_value(ast.send(symbol))
					}.compact.each { |descr|
						_bdd_add_free_text(item, descr, 'Bezeichnung')
					}
					item.qty = _value(ast.qty)
					_item_add_price(item, ast.pricenettopce, 'NettoPreis')
					_item_add_price(item, ast.pricenetto, 'NettoPreisME')
					_item_add_price(item, ast.discountpce, 'Grundrabatt')
					_item_add_price(item, ast.discount, 'GrundrabattME')
					_item_add_price(item, ast.extradiscountpce, 'Sonderrabatt')
					_item_add_price(item, ast.extradiscount, 'SonderrabattME')
					_item_add_price(item, ast.pricebruttopce, 'BruttoPreis')
					_item_add_price(item, ast.pricebrutto, 'BruttoPreisME')
				end
				def _bdd_assemble_transaction(transaction, ast)
					if(datestr = _value(ast.rdate))
						transaction.status_date = Date.parse(datestr)
					end
					transaction.add_id('Customer', _value(ast.commission))
					seller = Model::Party.new
					seller.role = 'Seller'
					transaction.add_party(seller)
					customer = Model::Party.new
					customer.role = 'Customer'
					if(emp = _value(ast.employee))
						employee = _customer_add_employee(customer)
						name = Model::Name.new
						name.text = emp
						employee.name = name
					end
					transaction.add_party(customer)
				end
				def _bdd_transaction_type(bdd)
					unless((bsr = bdd.bsr) && (noun = bsr.noun))
						raise 'Invalid Conversion: there was no valid Header in AST'
					end
					noun
				end
				def _customer_add_employee(customer)
					employee = Model::Party.new
					employee.role = 'Employee'
					customer.add_party(employee)
					employee
				end
				def _delivery_add_item(delivery, ast)
					item = Model::DeliveryItem.new
					_bdd_assemble_item(item, ast)
					if(datestr = _value(ast.ddate))
						item.delivery_date = Date.parse(datestr)
					end
					delivery.add_item(item)
				end
				def _invoice_add_item(invoice, ast)
					item = Model::InvoiceItem.new
					_bdd_assemble_item(item, ast)
					if(origin = _value(ast.origin))
						_item_add_part_info(item, 'Ursprungsland', origin)
					end
					if(customs = _value(ast.customs))
						_item_add_part_info(item, 'Zolltarifnr.', customs)
					end
					invoice.add_item(item)
				end
				def _item_add_part_info(item, dimension, value)
					info = Model::PartInfo.new
					info.dimension = dimension
					info.value = value 
					item.add_part_info(info)
				end
				def _item_add_price(item, ast, purpose)
					if(price = _value(ast))
						bdd_price = Model::Price.new
						bdd_price.purpose = purpose
						bdd_price.amount = (price.to_f * 100).to_i
						item.add_price(bdd_price)
					end
				end
				def _select_bdd_transaction(bdd)
					if(_bdd_transaction_type(bdd) == 'Invoice')
						bdd.invoices.last
					else
						bdd.deliveries.last
					end
				end
				def _value(node)
					unless(node.attributes.empty?)
						node.value
					end
				end
			end
		end
	end
end
