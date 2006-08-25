#!/usr/bin/env ruby
# Bdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'odba'

module XmlConv
	module Model
		class Bdd
      include ODBA::Persistable
      ODBA_SERIALIZABLE = ['@deliveries', '@invoices']
			attr_accessor :bsr
			attr_reader :deliveries, :invoices
			def initialize
				@deliveries = []
				@invoices = []
			end
			def add_delivery(delivery)
				@deliveries.push(delivery)
			end
			def add_invoice(invoice)
				@invoices.push(invoice)
			end
      def invoiced_amount
        @invoices.inject(0) { |memo, invoice|
          memo + invoice.get_price('SummePositionen').amount.to_f
        }
      end
		end
	end
end
