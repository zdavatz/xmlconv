#!/usr/bin/env ruby
# Bdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'odba'

module XmlConv
	module Model
		class Bdd
      include ODBA::Persistable
      ODBA_SERIALIZABLE = ['@deliveries', '@invoices', '@processing_logs']
			attr_accessor :bsr
			attr_reader :deliveries, :invoices, :processing_logs
			def initialize
				@deliveries = []
				@invoices = []
				@processing_logs = []
			end
			def add_delivery(delivery)
				@deliveries.push(delivery)
			end
			def add_invoice(invoice)
				@invoices.push(invoice)
			end
			def add_processing_log(log)
				@processing_logs.push(log)
			end
      def empty?
        @deliveries.empty? && @invoices.empty? && @processing_logs.empty?
      end
      def invoiced_amount
        @invoices.inject(0) { |memo, invoice|
          memo + invoice.get_price('SummePositionen').amount.to_f
        }
      end
		end
	end
end
