#!/usr/bin/env ruby
# Util::Invoicer -- xmlconv2 -- 03.08.2006 -- hwyss@ywesee.com

require 'ydim/config'
require 'ydim/client'

module XmlConv
	module Util
class Invoicer
  class << self
    def create_invoice(time_range, groups, date, currency='CHF')
      time = Time.now
      format = XmlConv::CONFIG.invoice_item_format
      ydim_connect { |client|
        ydim_inv = client.create_invoice(XmlConv::CONFIG.ydim_id)
        ydim_inv.description = sprintf(XmlConv::CONFIG.invoice_format,
                                       time_range.first.strftime("%d.%m.%Y"),
                                       (time_range.last - 1).strftime("%d.%m.%Y"))
        ydim_inv.date = date
        ydim_inv.currency = currency
        ydim_inv.payment_period = 30
        default_rate = XmlConv::CONFIG.commission
        item_data = groups.sort.collect { |group, bdds|
          rate = XmlConv::CONFIG.group_commissions[group] || default_rate
          amount = bdds.inject(0) { |memo, bdd| memo + bdd.invoiced_amount }
          {
            :price    =>  (amount * rate) / 100.0,
            :quantity =>  1,
            :text     =>  sprintf(format, group.to_s, currency, amount, bdds.size),
            :time			=>	Time.local(date.year, date.month, date.day),
            :unit     =>  ("%3.2f%%" % rate).gsub(/0+%/, '%'),
          }
        }
        client.add_items(ydim_inv.unique_id, item_data)
        ydim_inv
      }
    end
    def group_by_partner(transactions)
      groups = {}
      transactions.each { |transaction|
        (groups[transaction.partner] ||= []).push(transaction.model)
      }
      groups
    end
    def run(time_range, transactions, date)
      unless(transactions.empty?)
        invoice = create_invoice(time_range, group_by_partner(transactions), 
                                 date)
        send_invoice(invoice.unique_id)
      end
    end
    def send_invoice(invoice_id)
      ydim_connect { |client| client.send_invoice(invoice_id) }
    end
    def ydim_connect(&block)
      config = YDIM::Client::CONFIG
      server = DRbObject.new(nil, config.server_url)
      client = YDIM::Client.new(config)
      key = OpenSSL::PKey::DSA.new(File.read(config.private_key))
      client.login(server, key)
      block.call(client)
    ensure
      client.logout if(client)
    end
  end
end
  end
end
