#!/usr/bin/env ruby
# Delivery -- xmlconv -- 01.06.2004 -- hwyss@ywesee.com

require 'model/party_container'

module XmlConv
	module Model
		class Delivery
			attr_accessor :delivery_id, :bsr
			attr_reader :items
			include PartyContainer
			def initialize
				@items = []
			end
			def add_item(item)
				@items.push(item)
			end
			def party_id
				@bsr.party_id unless(@bsr.nil?)
			end
		end
	end
end
