#!/usr/bin/env ruby
# Util::Validator -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/validator'

module XmlConv
	module Util
		class Validator < SBSM::Validator
			EVENTS = [
				:login, :logout, :sort, :transaction, :self, :home
			]
			STRINGS = [
				:sortvalue,
			]
			NUMERIC = [
				:transaction_id, :page
			]
		end
	end
end
