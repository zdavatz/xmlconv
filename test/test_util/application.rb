#!/usr/bin/env ruby
# XmlConv::TestApplication -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/application'
require 'mock'

module XmlConv
	module Conversion
		def const_get(symbol)
			if(symbol.is_a?(Mock))
				symbol
			else
				super
			end
		end
		module_function :const_get
	end
	module Util
		class TestApplication < Test::Unit::TestCase
			def setup
				@app = Util::Application.new
				@app.init
			end
			def test_attr_readers
				assert_respond_to(@app, :transactions)
				assert_respond_to(@app, :failed_transactions)
			end
			def test_execute
				transaction = Mock.new('Transaction')
				cache = Mock.new('Cache')
				cache.__next(:transaction) { |block|
					block.call
				}
				cache.__next(:store) { |transactions|
					assert_equal(@app.transactions, transactions)
				}
				ODBA.cache_server = cache
				transaction.__next(:transaction_id=) { |id|
					assert_equal(1, id)
				}
				transaction.__next(:execute) { }
				transaction.__next(:notify) { }
				assert_equal([], @app.transactions)
				assert_equal(0, @app.transactions.size)
				@app.execute(transaction)
				assert_equal([transaction], @app.transactions)
				transaction.__verify
				cache.__verify
			ensure
				ODBA.cache_server = nil
			end
			def test_execute__survive_notification_failure
				transaction = Mock.new('Transaction')
				cache = Mock.new('Cache')
				cache.__next(:transaction) { |block|
					block.call
				}
				cache.__next(:store) { |transactions|
					assert_equal(@app.transactions, transactions)
				}
				ODBA.cache_server = cache
				transaction.__next(:transaction_id=) { |id|
					assert_equal(1, id)
				}
				transaction.__next(:execute) { }
				transaction.__next(:notify) { 
					raise Net::SMTPFatalError, 'could not send email'
				}
				assert_equal([], @app.transactions)
				assert_equal(0, @app.transactions.size)
				@app.execute(transaction)
				assert_equal([transaction], @app.transactions)
				transaction.__verify
				cache.__verify
			ensure
				ODBA.cache_server = nil
			end
			def test_execute__notify_errors
				transaction = Mock.new('Transaction')
				cache = Mock.new('Cache')
				cache.__next(:transaction) { |block|
					block.call
				}
				cache.__next(:store) { |transactions|
					assert_equal(@app.transactions, transactions)
				}
				ODBA.cache_server = cache
				transaction.__next(:transaction_id=) { |id|
					assert_equal(1, id)
				}
				transaction.__next(:execute) {
					raise 'oops, something went wrong'
				}
				transaction.__next(:error=) { }
				transaction.__next(:notify) { }
				assert_equal([], @app.transactions)
				assert_equal(0, @app.transactions.size)
				@app.execute(transaction)
				assert_equal([transaction], @app.transactions)
				transaction.__verify
				cache.__verify
			ensure
				ODBA.cache_server = nil
			end
			def test_dumpable
				assert_nothing_raised { Marshal.dump(@app) }
			end
			def test_next_transaction_id
				assert_equal([], @app.transactions)
				assert_equal(1, @app.next_transaction_id)
				assert_equal(2, @app.next_transaction_id)
				assert_equal(3, @app.next_transaction_id)
				trans1 = Mock.new('Transaction1')
				trans2 = Mock.new('Transaction2')
				@app.transactions.push(trans1)
				@app.transactions.push(trans2)
				@app.instance_variable_set('@next_transaction_id', nil)
				trans1.__next(:transaction_id) { 6 }
				trans2.__next(:transaction_id) { 3 }
				assert_equal(7, @app.next_transaction_id)
				trans1.__verify
				trans2.__verify
			end
			def test_odba_exclude_vars
				@app.instance_variable_set('@next_transaction_id', 10)
				@app.instance_eval('self.odba_replace_excluded!')	
				assert_nil(@app.instance_variable_get('@next_transaction_id'))
			end
			def test_transaction
				trans1 = Mock.new('Transaction1')
				trans2 = Mock.new('Transaction2')
				trans3 = Mock.new('Transaction2')
				@app.transactions.push(trans1)
				@app.transactions.push(trans2)
				trans2.__next(:transaction_id) { 2 }
				trans1.__next(:transaction_id) { 1 }
				assert_equal(trans1, @app.transaction(1))
				trans1.__verify
				trans2.__verify
				@app.transactions.push(trans3)
				trans3.__next(:transaction_id) { 5 }
				trans1.__next(:transaction_id) { 1 }
				trans2.__next(:transaction_id) { 2 }
				assert_equal(trans2, @app.transaction(2))
				trans1.__verify
				trans2.__verify
				trans3.__verify
				trans3.__next(:transaction_id) { 5 }
				trans3.__next(:transaction_id) { 5 }
				assert_equal(trans3, @app.transaction(5))
				trans1.__verify
				trans2.__verify
				trans3.__verify
				trans3.__next(:transaction_id) { 5 }
				trans3.__next(:transaction_id) { 5 }
				assert_equal(trans3, @app.transaction('5'))
				trans1.__verify
				trans2.__verify
				trans3.__verify
			end
		end
	end
end
