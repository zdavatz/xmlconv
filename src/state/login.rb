#!/usr/bin/env ruby
# State::Login -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/state'
require 'view/login'
require 'state/transactions'

module XmlConv
	module State
		class Login < SBSM::State
			VIEW = View::Login
			def login
				if(@session.login)
					Transactions.new(@session, @session.transactions)
				else
					self
				end
			end
		end
	end
end
