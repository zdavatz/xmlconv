#!/usr/bin/env ruby
# XmlConv::Application -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

require 'sbsm/drbserver'
require 'state/global'
require 'util/polling_manager'
require 'util/session'
require 'util/transaction'
require 'util/validator'
require 'odba'

module XmlConv
	module Util
		class Application
			attr_reader :transactions, :failed_transactions
			include ODBA::Persistable
			ODBA_EXCLUDE_VARS = ['@next_transaction_id']
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
				#puts "transaction_id #{transaction.transaction_id}"
				transaction.execute
				#puts "exectuded"
				@transactions.push(transaction)
				@transactions.odba_store
			rescue Exception => error
				#puts "rescue #{error}"
				transaction.error = error
				#puts "in transaction"
				@failed_transactions.push(transaction)
				#puts "in transactions"
				@failed_transactions.odba_store
				#puts "persistent"
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
	POLLING_INTERVAL = 60 #* 15
	def initialize
		@system = ODBA.cache_server.fetch_named('XmlConv', self) { 
			XmlConv::Util::Application.new
		}
		if(self::class::POLLING_INTERVAL)
			start_polling
		end
		super(@system)
	end
	def start_polling
		@polling_thread = Thread.new {
			loop {
				begin
					#puts "polling"
					XmlConv::Util::PollingManager.new(@system).poll_sources
					#puts "done"
				rescue Exception => exc
					puts exc
				end
				sleep(self::class::POLLING_INTERVAL)
			}
		}
	end
end
