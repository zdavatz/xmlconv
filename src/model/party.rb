#!/usr/bin/env ruby
# Party -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'model/party_container'

module XmlConv
	module Model
		class Party
			attr_accessor :role, :name, :address
			include PartyContainer
		end
	end
end
