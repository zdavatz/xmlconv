#!/usr/bin/env ruby
# Model::Invoice -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

require 'xmlconv/model/transaction'

module XmlConv
	module Model
		class Invoice < Transaction
			attr_reader :delivery_id, :invoice_id
			def add_delivery_id(domain, idstr)
				@delivery_id = [domain, idstr]
			end
			def add_invoice_id(domain, idstr)
				@invoice_id = [domain, idstr]
			end
		end
	end
end
