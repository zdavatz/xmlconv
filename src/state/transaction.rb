#!/usr/bin/env ruby
# State::Transaction -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/transaction'

module XmlConv
	module State
		class Transaction < Global
			VIEW = View::Transaction
		end
	end
end
