#!/usr/bin/env ruby
# XmlConv::Application -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

require 'sbsm/drbserver'
require 'state/global'
require 'util/transaction'
require 'util/session'
require 'util/validator'
require 'odba'

module XmlConv
	module Util
		class Application
			attr_reader :transactions, :failed_transactions
			include ODBA::Persistable
			ODBA_EXCLUDE_VARS = ['@next_transaction_id']
			PASSWORD = 
			def initialize
				@transactions = []
				@failed_transactions = []
			end
=begin
			def convert(input, reader, writer, destination, request)
				transaction = Util::Transaction.new
				transaction.input = input
				transaction.reader = reader
				transaction.writer = writer
				transaction.destination = destination
=end
			def execute(transaction)
				transaction.transaction_id = next_transaction_id
				transaction.execute
				@transactions.push(transaction)
				@transactions.odba_store
			rescue
				@failed_transactions.push(transaction)
				@failed_transactions.odba_store
			end
			def next_transaction_id
				@next_transaction_id ||= @transactions.collect { |transaction|
					transaction.transaction_id.to_i
				}.max.to_i
				@next_transaction_id += 1
			end
			def transaction(transaction_id)
				transaction_id = transaction_id.to_i
				if((last_id = @transactions.last.transaction_id) \
					&& (last_id >= transaction_id))
					start = (transaction_id - last_id - 1) 
					if(start + @transactions.size < 0)
						start = 0
					end
					@transactions[start..-1].each { |trans|
						return trans if(trans.transaction_id == transaction_id)
					}
				end
			end
		end
	end
end

class XmlConvApp < SBSM::DRbServer
	SESSION = XmlConv::Util::Session
	VALIDATOR = XmlConv::Util::Validator
	def initialize
		@system = ODBA.cache_server.fetch_named('XmlConv', self) { 
			XmlConv::Util::Application.new
		}
		super(@system)
	end
end