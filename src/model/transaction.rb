#!/usr/bin/env ruby
# Model::Transaction -- xmlconv2 -- 23.06.2004 -- hwyss@ywesee.com

require 'model/id_container'
require 'model/item_container'
require 'model/party_container'
require 'model/price_container'

module XmlConv
	module Model
		class Transaction
			include IdContainer
			include ItemContainer
			include PartyContainer
			include PriceContainer
			attr_accessor :agreement, :free_text, :status, :status_date
			attr_accessor :customer, :seller
		end
	end
end
