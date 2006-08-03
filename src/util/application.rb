#!/usr/bin/env ruby
# XmlConv::Application -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

require 'sbsm/drbserver'
require 'state/global'
require 'util/invoicer'
require 'util/polling_manager'
require 'util/session'
require 'util/transaction'
require 'util/validator'
require 'thread'
require 'odba'

module XmlConv
	module Util
		class Application
			attr_reader :transactions, :failed_transactions
			include ODBA::Persistable
			ODBA_EXCLUDE_VARS = ['@next_transaction_id', '@id_mutex']
			def initialize
				@transactions = []
				@failed_transactions = []
			end
			def init
				@id_mutex = Mutex.new
			end
			def execute(transaction)
				_execute(transaction)
				transaction.notify
			rescue Exception => error
				## survive notification failure
			end
			def _execute(transaction)
				transaction.transaction_id = next_transaction_id
				transaction.execute
			rescue Exception => error
				transaction.error = error
			ensure
				@transactions.push(transaction)
				ODBA.transaction {
					@transactions.odba_store
				}
			end
			def next_transaction_id
				@id_mutex.synchronize {
					@next_transaction_id ||= @transactions.collect { |transaction|
						transaction.transaction_id.to_i
					}.max.to_i
					@next_transaction_id += 1
				}
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
      def send_invoice(time_range, date = Date.today)
        transactions = @transactions.select { |trans| 
          time_range.include?(trans.commit_time)
        }
        Util::Invoicer.run(time_range, transactions, date)
      end
		end
	end
end

class XmlConvApp < SBSM::DRbServer
	SESSION = XmlConv::Util::Session
	VALIDATOR = XmlConv::Util::Validator
	POLLING_INTERVAL = 60 #* 15
	attr_reader :polling_thread, :dispatch_queue, :dispatcher_thread
	def initialize
		@system = ODBA.cache.fetch_named('XmlConv', self) { 
			XmlConv::Util::Application.new
		}
		@system.init
		@dispatch_queue = []
		@dispatch_mutex = Mutex.new
		if(self::class::POLLING_INTERVAL)
			start_polling
		end
		start_dispatcher
		start_invoicer
		super(@system)
	end
	def dispatch(transaction)
		@dispatch_mutex.synchronize {
			@dispatch_queue.push(transaction)
		}
		@dispatcher_thread.wakeup
	end
	def start_dispatcher
		@dispatcher_thread = Thread.new {
			Thread.current.abort_on_exception = true
			loop { 
				Thread.stop
				while(!@dispatch_queue.empty?)
					transaction = nil
					@dispatch_mutex.synchronize {
						transaction = @dispatch_queue.shift
					}
					@system.execute(transaction)
				end
			}
		}
	end
  def start_invoicer
    @invoicer_thread = Thread.new {
      loop { 
        this_month = Date.today
        next_month = this_month >> 1
        strt = Time.local(this_month.year, this_month.month)
        stop = Time.local(next_month.year, next_month.month)
        sleep(stop - Time.now)
        @system.send_invoice(strt...stop)
      }
    }
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
