#!/usr/bin/env ruby
# Party -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'model/party_container'
require 'model/id_container'

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
			def acc_id
				self.ids['ACC']
			end
		end
	end
end
