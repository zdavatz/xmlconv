#!/usr/bin/env ruby
# Model::Transaction -- xmlconv2 -- 23.06.2004 -- hwyss@ywesee.com

require 'xmlconv/model/freetext_container'
require 'xmlconv/model/id_container'
require 'xmlconv/model/item_container'
require 'xmlconv/model/party_container'
require 'xmlconv/model/price_container'

module XmlConv
	module Model
		class Transaction
			include IdContainer
			include ItemContainer
			include FreeTextContainer
			include PartyContainer
			include PriceContainer
			attr_accessor :agreement, :status, :status_date, 
        :transport_cost
			def customer_id
				self.id_table['customer']
			end
			def reference_id
				self.id_table['acc']
			end
		end
	end
end
