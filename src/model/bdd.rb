#!/usr/bin/env ruby
# Bdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class Bdd
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
		end
	end
end
