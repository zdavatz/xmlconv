#!/usr/bin/env ruby
# Delivery -- xmlconv -- 01.06.2004 -- hwyss@ywesee.com

require 'model/party_container'
require 'model/id_container'
require 'model/price_container'

module XmlConv
	module Model
		class Delivery
			attr_accessor :bsr, :agreement
			attr_reader :items, :customer_id
			attr_reader :seller, :customer
			include PartyContainer
			include IdContainer
			include PriceContainer
			def initialize
				@items = []
			end
			def add_item(item)
				@items.push(item)
			end
			def bsr_id
				@bsr.bsr_id unless(@bsr.nil?)
			end
		end
	end
end
