#!/usr/bin/env ruby
# Model::Invoice -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

require 'model/transaction'

module XmlConv
	module Model
		class Invoice < Transaction
			attr_reader :delivery_id
			def add_delivery_id(domain, idstr)
				@delivery_id = [domain, idstr]
			end
		end
	end
end
