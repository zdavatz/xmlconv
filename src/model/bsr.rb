#!/usr/bin/env ruby
# Bsr -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'model/party_container'

module XmlConv
	module Model
		class Bsr 
			include PartyContainer
			def bsr_id
				@customer.party_id unless(@customer.nil?)
			end
		end
	end
end
