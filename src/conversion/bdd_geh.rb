#!/usr/bin/env ruby
# Conversion::BddGeh -- xmlconv2 -- 18.05.2006 -- hwyss@ywesee.com

require 'rexml/document'

module XmlConv
  module Conversion
    class BddGeh
class << self
  SELLER_ID = 663 # DTSTTCPW-approach. Could also be passed in, e.g. from the
                  # PollingMission
  def convert(bdd)
    docs = []
    bdd.deliveries.each { |delivery|
      skeleton = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<OrderResponse />
      EOS
      doc = REXML::Document.new(skeleton)
      _xml_add_bdd_delivery(doc.root, delivery)
      docs.push(doc)
    }
    bdd.invoices.each { |invoice|
      skeleton = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<Invoice />
      EOS
      doc = REXML::Document.new(skeleton)
      _xml_add_bdd_invoice(doc.root, invoice)
      docs.push(doc)
    }
    docs
  end
  def _utf8(str)
    Iconv.iconv('UTF8', 'ISO-8859-1', str).first.strip
  rescue
    str
  end
  def _xml_add_base_item_detail(xml_item, item, type=:order_response)
    tag = case type
          when :invoice
            'InvoiceBaseItemDetail'
          else
            'BaseItemDetail'
          end
    xml_base = REXML::Element.new(tag)
    _xml_add_item_line_no(xml_base, item.line_no)
    _xml_add_item_part_id(xml_base, item)
    _xml_add_item_quantity(xml_base, item)
    xml_item.add_element(xml_base)
  end
  def _xml_add_bdd_delivery(xml_root, delivery)
    _xml_add_delivery_header(xml_root, delivery)
    _xml_add_bdd_detail(xml_root, delivery)
  end
  def _xml_add_bdd_detail(xml_root, delivery)
    xml_detail = _xml_element("OrderResponseDetail")
    xml_list = _xml_element('ListOfOrderResponseItemDetail')
    delivery.items.each { |item|
      _xml_add_item(xml_list, item)
    }
    xml_detail.add_element(xml_list)
    xml_root.add_element(xml_detail)
  end
  def _xml_add_bdd_invoice(xml_root, invoice)
    _xml_add_invoice_header(xml_root, invoice)
    _xml_add_invoice_detail(xml_root, invoice)
    _xml_add_invoice_summary(xml_root, invoice)
  end
  def _xml_add_bdd_party(xml_container, party, employee=nil)
    role = party.role
    case role
    when 'Customer'
      party.parties.each { |part|
        _xml_add_bdd_party(xml_container, part, party.employee)
      }
    when 'BillTo'
      _xml_add_party(xml_container, party, employee, 'BuyerParty')
    when 'Employee'
    else
      _xml_add_party(xml_container, party, employee, sprintf("%sParty", role))
    end
  end
  def _xml_add_party(xml_container, party, employee, tagname)
    xml_name_party = _xml_element(tagname)
    xml_party = _xml_element('Party')
    if(pid = party.party_id)
      xml_party.add_element(_xml_nested_text(pid, 'PartyID', 'Identifier',
                                             'Ident'))
    end
    if(addr = party.address)
      _xml_add_name_address(xml_party, addr)
    end
    if(employee)
      xml_party.add_element(_xml_nested_text(employee.name.to_s, 
                            'OrderContact', 'Contact', 'ContactName'))
    end
    xml_name_party.add_element(xml_party)
    xml_container.add_element(xml_name_party)
  end
  def _xml_add_delivery_detail(xml_item, item)
    if(date = item.delivery_date)
      xml_item.add_element(_xml_nested_text(date.strftime('%Y%m%d'),
                           'DeliveryDetail', 'ListOfScheduleLine', 
                           'ScheduleLine', 'RequestedDeliveryDate'))
    end
  end
  def _xml_add_delivery_header(xml_root, delivery)
    xml_header = _xml_element("OrderResponseHeader")
    xml_header.add_element(_xml_nested_text(delivery.reference_id, 
                           "OrderResponseNumber", "BuyerOrderResponseNumber"))
    xml_header.add_element(_xml_nested_text(delivery.customer_id, 
                           'OrderReference', 'Reference', 'RefNum'))
    if(date = delivery.status_date)
      str = date.strftime('%Y%m%d%H%M%S')
      xml_header.add_element(_xml_nested_text(str, 'OrderResponseIssueDate'))
    end
    if((seller = delivery.seller) && !seller.party_id)
      seller.add_id('ACC', SELLER_ID)
    end
    delivery.parties.each { |party|
      _xml_add_bdd_party(xml_header, party)
    }
    xml_root.add_element(xml_header)
  end
  def _xml_add_invoice_detail(xml_root, invoice)
    xml_detail = _xml_element('InvoiceDetail')
    xml_list = _xml_element('ListOfInvoiceItemDetail')
    invoice.items.each { |item|
      _xml_add_invoice_item(xml_list, item)
    }
    xml_detail.add_element(xml_list)
    xml_root.add_element(xml_detail)
  end
  def _xml_add_invoice_header(xml_root, invoice)
    xml_header = _xml_element('InvoiceHeader')
    xml_header.add_element(_xml_nested_text(invoice.invoice_id.last, 
                           'InvoiceNumber', 'Reference', 'RefNum'))
    if(date = invoice.status_date)
      xml_header.add_element(_xml_nested_text(date.strftime('%Y%m%d%H%M%S'),
                                              'InvoiceIssueDate'))
    end
    _xml_add_invoice_references(xml_header, invoice)
    if(party = invoice.seller)
      unless(party.party_id)
        party.add_id('ACC', SELLER_ID)
      end
      _xml_add_bdd_party(xml_header, party)
    end
    xml_root.add_element(xml_header)
  end
  def _xml_add_invoice_item(xml_elm, item)
    xml_item = _xml_element('InvoiceItemDetail')
    _xml_add_base_item_detail(xml_item, item, :invoice)
    _xml_add_pricing_detail(xml_item, item, :invoice)
    xml_elm.add_element(xml_item)
    xml_item
  end
  def _xml_add_invoice_references(xml_header, invoice)
    xml_refs = _xml_element('InvoiceReferences')
    xml_refs.add_element(_xml_nested_text(invoice.delivery_id.last, 
                         'PurchaseOrderReference', 'PurchaseOrderNumber',
                         'Reference', 'RefNum'))
    xml_header.add_element(xml_refs)
  end
  def _xml_add_invoice_summary(xml_root, invoice)
    xml_summary = _xml_nested_text(invoice.items.size, 'InvoiceSummary', 
                                   'NumberOfLines')
    xml_totals = _xml_element('InvoiceTotals')
    if(price = invoice.get_price('SummePositionen'))
      xml_net = _xml_nested_text(sprintf('%1.2f', price.amount),
                                 'NetValue', 'MonetaryValue', 'MonetaryAmount')
      xml_totals.add_element(xml_net)
    end
    if(price = invoice.get_price('Mehrwertsteuer'))
      xml_tax = _xml_nested_text(sprintf('%1.2f', price.amount),
                                 'TotalTax', 'MonetaryValue', 'MonetaryAmount')
      xml_totals.add_element(xml_tax)
    end
    if(price = invoice.get_price('Endbetrag'))
      xml_total = _xml_nested_text(sprintf('%1.2f', price.amount),
                                   'TotalAmountPlusTax', 'MonetaryValue', 
                                   'MonetaryAmount')
      xml_totals.add_element(xml_total)
    end
    xml_summary.add_element(xml_totals)
    xml_root.add_element(xml_summary)
  end
  def _xml_add_item(xml_elm, item)
    xml_item = _xml_element('OrderResponseItemDetail')
    _xml_add_base_item_detail(xml_item, item)
    _xml_add_pricing_detail(xml_item, item)
    _xml_add_delivery_detail(xml_item, item)
    xml_elm.add_element(xml_item)
    xml_item
  end
  def _xml_add_item_line_no(xml_item, line_no)
    xml_item.add_element(_xml_nested_text(line_no, 'LineItemNum', 
                                          'BuyerLineItemNum'))
  end
  def _xml_add_item_part_id(xml_item, item)
    xml_ids = _xml_element('ItemIdentifiers')
    xml_pns = _xml_element('PartNumbers')
    item.ids.each { |domain, idstr|
      tagname = case domain
                when 'ET-Nummer'
                  'BuyerPartNumber'
                else 
                  'SellerPartNumber'
                end
      xml_pns.add_element(_xml_nested_text(idstr, tagname, 'PartNum', 'PartID'))
    }
    xml_ids.add_element(xml_pns)
    xml_item.add_element(xml_ids)
  end
  def _xml_add_item_quantity(xml_item, item)
    xml_total = _xml_element('TotalQuantity')
    xml_qty = _xml_nested_text(item.qty, 'Quantity', 'QuantityValue')
    xml_qty.add_element(_xml_nested_text('EA', 'UnitOfMeasurement', 'UOMCoded'))
    xml_total.add_element(xml_qty)
    xml_item.add_element(xml_total)
  end
  def _xml_add_name_address(xml_party, addr)
    xml_name_address = _xml_element('NameAddress')
    lines = addr.lines.dup
    street = lines.pop
    name = lines.shift
    xml_name_address.add_element(_xml_nested_text(name.to_s, 'Name1'))
    unless(lines.empty?)
      xml_name_address.add_element(_xml_nested_text(lines.join(" "), 'Name2'))
    end
    xml_name_address.add_element(_xml_nested_text(street, 'Street'))
    xml_name_address.add_element(_xml_nested_text(addr.zip_code, 'PostalCode'))
    xml_name_address.add_element(_xml_nested_text(addr.city, 'City'))
    xml_party.add_element(xml_name_address)
  end
  def _xml_add_pricing_detail(xml_item, item, type=:order_response)
    tag = 'PricingDetail'
    total = 'TotalValue'
    case type
    when :invoice
      tag = 'InvoicePricingDetail'
      total = 'InvoiceCurrencyTotalValue'
    end
    xml_base = _xml_element(tag)
    if(price = item.get_price('NettoPreis'))
      xml_list = _xml_element('ListOfPrice')
      xml_price = _xml_element('Price')
      xml_unit = _xml_nested_text('CHF', 'UnitPrice', 'Currency', 
                                  'CurrencyCoded')
      xml_value = _xml_nested_text(sprintf('%1.2f', price.amount), 
                                   'UnitPriceValue')
      xml_unit.add_element(xml_value)
      xml_price.add_element(xml_unit)
      xml_list.add_element(xml_price)
      xml_base.add_element(xml_list)
    end
    if(price = item.get_price('NettoPreisME'))
      xml_price = _xml_nested_text(sprintf('%1.2f', price.amount), 
                    total, 'MonetaryValue', 'MonetaryAmount')
      xml_base.add_element(xml_price)
    end
    xml_item.add_element(xml_base)
  end
  def _xml_element(name)
    REXML::Element.new(name)
  end
  def _xml_nested_text(text, *hierarchy)
    parent = _xml_element(hierarchy.pop)
    parent.text = _utf8(text)
    hierarchy.reverse.each { |name|
      child = parent
      parent = _xml_element(name)
      parent.add_element(child)
    }
    parent
  end
end
    end
  end
end
