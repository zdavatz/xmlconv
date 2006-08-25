#!/usr/bin/env ruby
# Util::KnownUser -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/user'
require 'xmlconv/state/transactions'

module XmlConv
	module Util
		class KnownUser < SBSM::KnownUser
			HOME = State::Transactions
			NAVIGATION = [
				:home, :logout
			]
		end
	end
end
