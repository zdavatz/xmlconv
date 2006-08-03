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
      format = "Umsatzbeteiligung %s\nCHF %1.2f Umsatz\naus %i Rechnungs-Übermittlungen"
      ydim_connect { |client|
        ydim_inv = client.create_invoice(YDIM_ID)
        ydim_inv.description = sprintf("Umsatzbeteiligung %s-%s", 
                                       time_range.first.strftime("%d.%m.%Y"),
                                       (time_range.last - 1).strftime("%d.%m.%Y"))
        ydim_inv.date = date
        ydim_inv.currency = currency
        ydim_inv.payment_period = 30
        item_data = groups.sort.collect { |group, bdds|
          amount = bdds.inject(0) { |memo, bdd| memo + bdd.invoiced_amount }
          {
            :price    =>  (amount * 3.0) / 1000.0,
            :quantity =>  1,
            :text     =>  sprintf(format, group.to_s, amount, bdds.size),
            :time			=>	Time.local(date.year, date.month, date.day),
            :unit     =>  "0.3%",
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
