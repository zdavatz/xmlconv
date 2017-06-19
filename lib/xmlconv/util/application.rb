#!/usr/bin/env ruby
# XmlConv::Application -- xmlconv  -- 10.05.2012 -- yasaka@ywesee.com
# XmlConv::Application -- xmlconv  -- 29.09.2011 -- mhatakeyama@ywesee.com
# XmlConv::Application -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

require 'drb/drb'
require 'odba'
require 'csv'
require 'sbsm/admin_server'
require 'xmlconv/config'
require 'xmlconv/state/global'
require 'xmlconv/util/invoicer'
require 'xmlconv/util/polling_manager'
require 'xmlconv/util/session'
require 'xmlconv/util/transaction'
require 'xmlconv/util/validator'
require 'odba/connection_pool'
require 'xmlconv/util/autoload'
require 'thread'
require 'xmlconv/model/bdd'

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
        has_error = false
        transaction.transaction_id = next_transaction_id
        SBSM.info "Starting new transation #{transaction.transaction_id}"
        transaction.execute
        res = transaction.postprocess
        SBSM.info "Postprocessed transation #{transaction.transaction_id} res #{res.class}"
        res
      rescue Exception => error
        SBSM.info "error transation #{transaction.transaction_id} error #{error} \n#{error.backtrace}"
        transaction.error = error
      ensure
        SBSM.info "ensure transation #{transaction.transaction_id}"
        res = ODBA.transaction {
          transaction.odba_store
          @transactions.push(transaction)
          @transactions.odba_isolated_store
        }
        SBSM.info "has_error is #{has_error} ensure transation #{transaction.transaction_id} res is #{res}" if has_error
        res
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

def XmlConv.start_server
 XmlConv::Util.autoload(XmlConv::CONFIG.plugin_dir, 'plugin')
 XmlConv::Util.autoload(XmlConv::CONFIG.postproc_dir, 'postproc')
  Mail.defaults do
    delivery_method(:smtp, address: XmlConv::CONFIG.smtp_server, port: XmlConv::CONFIG.smtp_port,
                    domain: XmlConv::CONFIG.smtp_domain, user_name: XmlConv::CONFIG.smtp_user,
                    password:  XmlConv::CONFIG.smtp_pass, authentication: XmlConv::CONFIG.smtp_authtype,
                    enable_starttls_auto: true)
  end

  ODBA.storage.dbi = ODBA::ConnectionPool.new("DBI:Pg:#{XmlConv::CONFIG.db_name}",
                                              XmlConv::CONFIG.db_user, XmlConv::CONFIG.db_auth)
  ODBA.cache.setup
  puts "#{Time.now}: Prefetching cache. This may take a minute or two"
  ODBA.cache.prefetch
  $0 = XmlConv::CONFIG.program_name
  puts "#{Time.now}: Prefetching finshed program name is #{$0}"
  app = XmlConvApp.new
  DRb.start_service(XmlConv::CONFIG.server_url, app)
  SBSM.logger.info(XmlConv::CONFIG.program_name) { "drb-service listening on #{XmlConv::CONFIG.server_url}" }
  puts "#{Time.now}: start_server done returning #{app.class}"
  app
end

class XmlConvApp < SBSM::AdminServer
	attr_reader :app, :persistence_layer, :polling_thread, :dispatch_queue, :dispatcher_thread
  POLLING_INTERVAL = 60 #* 15
	def initialize(app: XmlConv::Util::RackInterface.new)
    @rack_app = app
    super(app: app)
		@persistence_layer = ODBA.cache.fetch_named('XmlConv', self) do XmlConv::Util::Application.new end
		@persistence_layer.init
		@dispatch_queue = Queue.new
    @polling_interval = XmlConv::CONFIG.polling_interval || self::class::POLLING_INTERVAL
    puts "@polling_interval is #{@polling_interval} @persistence_layer is #{@persistence_layer.class}"
    start_polling  if @polling_interval
		start_dispatcher
		start_invoicer if XmlConv::CONFIG.run_invoicer
	end
	def dispatch(transaction)
    @dispatch_queue.push(transaction)
	end
  def execute_with_response(transaction)
    begin
      @persistence_layer.execute(transaction)
    rescue Exception => e
      puts "rescued #{e.class}"
    end
    transaction.response.to_s
  end
	def start_dispatcher
		@dispatcher_thread = Thread.new {
			Thread.current.abort_on_exception = true
			loop {
				@persistence_layer.execute(@dispatch_queue.pop)
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
        @persistence_layer.send_invoice(strt...stop)
      }
    }
  end
  def start_polling
		@polling_thread = Thread.new {
      Thread.current.abort_on_exception = true
			loop {
				begin
					XmlConv::Util::PollingManager.new(@persistence_layer).poll_sources
				rescue Exception => exc
					SBSM.logger.error(XmlConv::CONFIG.program_name) {
            [exc.class, exc.message].concat(exc.backtrace).join("\n")
          }
				end
				sleep(@polling_interval)
			}
		}
	end
end

