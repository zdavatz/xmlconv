#!/usr/bin/env ruby
# XmlConv::Application -- xmlconv  -- 29.09.2011 -- mhatakeyama@ywesee.com
# XmlConv::Application -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

require 'sbsm/drbserver'
require 'xmlconv/state/global'
require 'xmlconv/util/invoicer'
require 'xmlconv/util/polling_manager'
require 'xmlconv/util/session'
require 'xmlconv/util/transaction'
require 'xmlconv/util/validator'
require 'thread'
require 'odba'
require 'xmlconv/model/bdd'

require 'conversion/pharmacieplus_bdd'
require 'conversion/bdd_i2'
require 'postprocess/bbmb'

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
        transaction.postprocess
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
      def export_orders(first=Time.local(1990,1,1), last=Time.local(2037,1,1), output_file=nil)
        range=Range.new(first, last)
        output_file ||= "/home/ywesee/xmlconv_export/xmlconv_export.csv"
        open(output_file, "w") do |f|
          self.transactions.reverse.each do |t|
            if range.include?(t.commit_time)
              f.print t.output
            end
          end
        end
      end
		end
	end
end

class XmlConvApp < SBSM::DRbServer
	ENABLE_ADMIN = true
	SESSION = XmlConv::Util::Session
	VALIDATOR = XmlConv::Util::Validator
	POLLING_INTERVAL = 60 #* 15
	attr_reader :polling_thread, :dispatch_queue, :dispatcher_thread
	def initialize
		@system = ODBA.cache.fetch_named('XmlConv', self) { 
			XmlConv::Util::Application.new
		}
		@system.init
		@dispatch_queue = Queue.new
		if(self::class::POLLING_INTERVAL)
			start_polling
		end
		start_dispatcher
		start_invoicer if XmlConv::CONFIG.run_invoicer
		super(@system)
	end
	def dispatch(transaction)
    @dispatch_queue.push(transaction)
	end
  def execute_with_response(transaction)
    begin
      @system.execute(transaction)
    rescue Exception => e
      puts "rescued #{e.class}"
    end
    transaction.response.to_s
  end
	def start_dispatcher
		@dispatcher_thread = Thread.new {
			Thread.current.abort_on_exception = true
			loop { 
				@system.execute(@dispatch_queue.pop)
			}
		}
	end
  def start_invoicer
    @invoicer_thread = Thread.new {
      Thread.current.abort_on_exception = true
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
      Thread.current.abort_on_exception = true
			loop {
				begin
					XmlConv::Util::PollingManager.new(@system).poll_sources
				rescue Exception => exc
					XmlConv::LOGGER.error(XmlConv::CONFIG.program_name) { 
            [exc.class, exc.message].concat(exc.backtrace).join("\n")
          }
				end
				sleep(self::class::POLLING_INTERVAL)
			}
		}
	end
end

