#!/usr/bin/env ruby
# State::Global -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'xmlconv/state/login'
require 'xmlconv/state/transaction'
require 'xmlconv/state/transactions'

module XmlConv
	module State
		class Global < SBSM::State
			def logout
				@session.logout
				Login.new(@session, @model)
			end
			def transaction
				if((id = @session.user_input(:transaction_id)) \
					&& (transaction = @session.persistence_layer.transaction(id)))
					Transaction.new(@session, transaction)
				else
					self
				end
			end
			def home
				Transactions.new(@session, @session.persistence_layer.transactions)
			end
		end
	end
end
