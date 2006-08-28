#!/usr/bin/env ruby
# State::Login -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/state'
require 'xmlconv/view/login'
require 'xmlconv/state/transactions'

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
			def transaction
				if((id = @session.user_input(:transaction_id)) \
					&& (transaction = @session.transaction(id)))
					TransactionLogin.new(@session, transaction)
				else
					self
				end
			end
		end
		class TransactionLogin < SBSM::State
			VIEW = View::Login
			def login
				if(@session.login)
					Transaction.new(@session, @model)
				else
					self
				end
			end
		end
	end
end
