#!/usr/bin/env ruby
# Party -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'model/party_container'
require 'model/id_container'

module XmlConv
	module Model
		class Party
			attr_accessor :role, :address, :name
			attr_reader :acc_id
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
