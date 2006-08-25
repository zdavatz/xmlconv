#!/usr/bin/env ruby
# Party -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'xmlconv/model/party_container'
require 'xmlconv/model/id_container'

module XmlConv
	module Model
		class Party
			attr_accessor :role, :address, :name
			include PartyContainer
			include IdContainer
			def party_id
				sorted = self.ids.sort
				domain, value = sorted.first
				value
			end
		end
	end
end
