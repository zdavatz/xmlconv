#!/usr/bin/env ruby
# I2::TestParser -- xmlconv2 -- 28.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'i2/parser'

module XmlConv
	module I2
		class TestParser < Test::Unit::TestCase
			def setup
				@parser = XmlConv::I2.cached_parser
			end
			def test_parser_class
				assert_instance_of(GeneralizedLrParser, @parser)
			end
			def test_parse_header
				src = <<-EOS
"00" "Sender Identification" "Recipient Identification" 
"20040628" "1159" "CONFIRM" "1"
				EOS
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				assert_instance_of(ArrayNode, ast.records)
				header = ast.records.first
				assert_instance_of(SyntaxTree, header)
				assert_equal('Header', header.name)
				rtype = header.rtype
				assert_instance_of(SyntaxTree, rtype)
				assert_equal('00', rtype.value)
				sender = header.sender
				assert_instance_of(SyntaxTree, sender)
				assert_equal('Sender Identification', sender.value)
				recipient = header.recipient
				assert_instance_of(SyntaxTree, recipient)
				assert_equal('Recipient Identification', recipient.value)
				date = header.date
				assert_instance_of(SyntaxTree, date)
				assert_equal('20040628', date.value)
				time = header.time
				assert_instance_of(SyntaxTree, time)
				assert_equal('1159', time.value)
				mtype = header.mtype
				assert_instance_of(SyntaxTree, mtype)
				assert_equal('CONFIRM', mtype.value)
				test = header.test
				assert_instance_of(SyntaxTree, test)
				assert_equal('1', test.value)
			end
			def test_parse_incomplete_header
				src = <<-EOS
"00" "" "" "" "" "" ""
				EOS
				ast = nil
				assert_nothing_raised { 
					ast = @parser.parse(src)
				}
				header = ast.records.first
				assert_equal('Header', header.name)
			end
			def test_parse_commission
				# commented fields are not in the current version
				src = <<-EOS
"01" "456" "Receipt-Number" "20040627" "Order Number" 
"Commission Number" "OC" "Employee"
				EOS
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				comm = ast.records.first
				assert_instance_of(SyntaxTree, comm)
				assert_equal('Commission', comm.name)
				assert_equal('01', comm.rtype.value)
				assert_equal('456', comm.btype.value)
				assert_equal('Receipt-Number', comm.receipt.value)
				assert_equal('20040627', comm.rdate.value)
				#assert_equal('20040629', comm.ddate.value)
				assert_equal('Order Number', comm.reference.value)
				assert_equal('Commission Number', comm.commission.value)
				assert_equal('OC', comm.contact.value)
				assert_equal('Employee', comm.employee.value)
				#assert_equal('TE', comm.medium.value)
				#assert_equal('0041 1 350 85 87', comm.number.value)
			end
			def test_parse_incomplete_commission
				src = <<-EOS
"01" "" "" "" "" "" "" ""
				EOS
				ast = nil
				assert_nothing_raised { 
					ast = @parser.parse(src)
				}
				comm = ast.records.first
				assert_equal('Commission', comm.name)
			end
			def test_parse_address
				src = <<-EOS
"02" "BY" "Name1" "Name2" "Street" "City" "AddressCode" "Country"
				EOS
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				addr = ast.records.first
				assert_instance_of(SyntaxTree, addr)
				assert_equal('Address', addr.name)
				assert_equal('02', addr.rtype.value)
				assert_equal('BY', addr.atype.value)
				assert_equal('Name1', addr.name1.value)
				assert_equal('Name2', addr.name2.value)
				assert_equal('Street', addr.street.value)
				assert_equal('City', addr.city.value)
				assert_equal('AddressCode', addr.code.value)
				assert_equal('Country', addr.country.value)
			end
			def test_parse_incomplete_address
				src = <<-EOS
"02" "" "" "" "" "" "" ""
				EOS
				ast = nil
				assert_nothing_raised { 
					ast = @parser.parse(src)
				}
				addr = ast.records.first
				assert_equal('Address', addr.name)
			end
			def test_parse_header_text
				src = <<-EOS
"05" "A single Header-Text"
				EOS
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				text = ast.records.first
				assert_instance_of(SyntaxTree, text)
				assert_equal('HeaderText', text.name)
				assert_equal('05', text.rtype.value)
				assert_equal('A single Header-Text', text.text.value)
			end
			def test_parse_incomplete_header_text
				src = <<-EOS
"05" "" 
				EOS
				ast = nil
				assert_nothing_raised { 
					ast = @parser.parse(src)
				}
				text = ast.records.first
				assert_equal('HeaderText', text.name)
			end
			def test_parse_position__delivery
				src = <<-EOS
"10" "PositionNr" "EAN13" "IdBuyer"
"Quantity" "DeliveryDate" "PriceNetto" "PriceNetto * Quantity" "Discount" 
"Discount * Quantity" "Special Discount" "Special Discount * Quantity"
"PriceBrutto" "PriceBrutto * Quantity"
				EOS
				# commented fields are not in the current version
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				position = ast.records.first
				assert_instance_of(SyntaxTree, position)
				assert_equal('Position', position.name)
				assert_equal('10', position.rtype.value)
				assert_equal('PositionNr', position.lineno.value)
				assert_equal('EAN13', position.eancode.value)
				#assert_equal('IdSeller', position.sellercode.value)
				assert_equal('IdBuyer', position.buyercode.value)
				#assert_equal('Description 1', position.description1.value)
				#assert_equal('Description 2', position.description2.value)
				assert_equal('Quantity', position.qty.value)
				#assert_equal('Commission', position.commission.value)
				assert_equal('DeliveryDate', position.ddate.value)
				#assert_equal('QuantityUnit', position.qtyunit.value)
				#assert_equal('PriceUnit', position.priceunit.value)
				assert_equal('PriceNetto', position.pricenettopce.value)
				assert_equal('PriceNetto * Quantity', position.pricenetto.value)
				assert_equal('Discount', position.discountpce.value)
				assert_equal('Discount * Quantity', position.discount.value)
				assert_equal('Special Discount', position.extradiscountpce.value)
				assert_equal('Special Discount * Quantity', position.extradiscount.value)
				assert_equal('PriceBrutto', position.pricebruttopce.value)
				assert_equal('PriceBrutto * Quantity', position.pricebrutto.value)
				#assert_equal('VAT', position.vat.value)
				#assert_equal('OriginCountry', position.origin.value)
				#assert_equal('Customs', position.customs.value)
			end
			def test_parse_position__invoice
				src = <<-EOS
"10" "PositionNr" "EAN13" "IdBuyer"
"Quantity" "PriceNetto" "PriceNetto * Quantity" "Discount" 
"Discount * Quantity" "Special Discount" "Special Discount * Quantity" 
"PriceBrutto" "PriceBrutto * Quantity" "OriginCountry" "Customs"
				EOS
				# commented fields are not in the current version
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				position = ast.records.first
				assert_instance_of(SyntaxTree, position)
				assert_equal('Position', position.name)
				assert_equal('10', position.rtype.value)
				assert_equal('PositionNr', position.lineno.value)
				assert_equal('EAN13', position.eancode.value)
				#assert_equal('IdSeller', position.sellercode.value)
				assert_equal('IdBuyer', position.buyercode.value)
				#assert_equal('Description 1', position.description1.value)
				#assert_equal('Description 2', position.description2.value)
				assert_equal('Quantity', position.qty.value)
				#assert_equal('Commission', position.commission.value)
				#assert_equal('DeliveryDate', position.ddate.value)
				#assert_equal('QuantityUnit', position.qtyunit.value)
				#assert_equal('PriceUnit', position.priceunit.value)
				assert_equal('PriceNetto', position.pricenettopce.value)
				assert_equal('PriceNetto * Quantity', position.pricenetto.value)
				assert_equal('Discount', position.discountpce.value)
				assert_equal('Discount * Quantity', position.discount.value)
				assert_equal('Special Discount', position.extradiscountpce.value)
				assert_equal('Special Discount * Quantity', position.extradiscount.value)
				assert_equal('PriceBrutto', position.pricebruttopce.value)
				assert_equal('PriceBrutto * Quantity', position.pricebrutto.value)
				#assert_equal('VAT', position.vat.value)
				assert_equal('OriginCountry', position.origin.value)
				assert_equal('Customs', position.customs.value)
			end
			def test_parse_incomplete_position
				src = <<-EOS
"10" "" "" "" "" "" "" "" "" "" "" "" "" ""
				EOS
				ast = nil
				assert_nothing_raised { 
					ast = @parser.parse(src)
				}
				position = ast.records.first
				assert_instance_of(SyntaxTree, position)
				assert_equal('Position', position.name)
			end
			def test_parse_position_text
				src = <<-EOS
"15" "A single Position-Text"
				EOS
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				text = ast.records.first
				assert_instance_of(SyntaxTree, text)
				assert_equal('PositionText', text.name)
				assert_equal('15', text.rtype.value)
				assert_equal('A single Position-Text', text.text.value)
			end
			def test_parse_incomplete_position_text
				src = <<-EOS
"15" "" 
				EOS
				ast = nil
				assert_nothing_raised { 
					ast = @parser.parse(src)
				}
				text = ast.records.first
				assert_equal('PositionText', text.name)
			end
			def test_parse_total
				src = <<-EOS
"90" "Price Netto" "VAT %" "VAT Amount" "Price Brutto" "Agreement"
				EOS
				ast = @parser.parse(src)
				assert_instance_of(SyntaxTree, ast)
				total = ast.records.first
				assert_instance_of(SyntaxTree, total)
				assert_equal('Footer', total.name)
				assert_equal('90', total.rtype.value)
				assert_equal('Price Netto', total.pricenetto.value)
				assert_equal('VAT %', total.vatpercent.value)
				assert_equal('VAT Amount', total.vatamount.value)
				assert_equal('Price Brutto', total.pricebrutto.value)
				assert_equal('Agreement', total.agreement.value)
			end
			def test_parse_incomplete_total
				src = <<-EOS
"90" "" "" "" "" ""
				EOS
				ast = nil
				assert_nothing_raised { 
					ast = @parser.parse(src)
				}
				total = ast.records.first
				assert_equal('Footer', total.name)
			end
			def test_parse
				src = <<-EOS
"00" "Plica" "Winterhalter&Fenner" "20040630" "1621" "INVOIC" "0"
"01" "000" "00112327" "20040630" "PLVH-087/PLVH-087627" "D-473010 L" "OC" "SAD"
"02" "SE" "PLICA AG  ***** TEST *********" "" "ZUERCHERSTRASSE 350" "FRAUENFELD" "8500" "CH"
"02" "CU" "WINTERHALTER + FENNER AG" "" "BIRGISTRASSE 10" "WALLISELLEN" "8304" "CH"
"02" "EP" "RUSSO GIOVANNI" "" "" "" "" ""
"02" "BY" "WINTERHALTER + FENNER AG" "" "BIRGISTRASSE 10" "WALLISELLEN" "8304" "CH"
"02" "DP" "WINTERHALTER + FENNER AG" "FILIALE LITTAU" "GROSSMATTE 11 / POSTFACH" "LITTAU" "6014" "CH"
"10" "5" "" "121.763.703" "10" "0" "0" "0" "0" "0" "0" "0" "0" "" ""
"10" "10" "" "125.001.309" "600" "115" "690" "21.85" "131.1" "0" "0" "93.15" "558.9" "CZ" "Z08151515"
"10" "15" "" "125.001.509" "60" "275" "165" "27.5" "16.5" "0" "0" "247.5" "148.5" "" ""
"10" "20" "" "125.091.409" "180" "420" "756" "0" "0" "0" "0" "420" "756" "" ""
"10" "25" "" "125.293.400" "50" "371" "185.5" "129.9" "64.95" "0" "0" "241.1" "120.55" "" ""
"10" "30" "" "125.293.600" "100" "773" "773" "270.55" "270.55" "0" "0" "502.45" "502.45" "" ""
"10" "90" "" "125.293.700" "100" "1082" "1082" "378.7" "378.7" "0" "0" "703.3" "703.3" "" ""
"90" "2789.7" "7.60" "212" "3001.7" "10 Tage 3%, 30 Tage 2%, 60 Tage netto"
				EOS
				assert_nothing_raised {
					@parser.parse(src)
				}
			end
		end
	end
end
