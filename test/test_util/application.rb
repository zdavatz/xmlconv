#!/usr/bin/env ruby
# XmlConv::TestApplication -- xmlconv  -- 24.02.2011 -- mhatakeya@ywesee.com
# XmlConv::TestApplication -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/util/application'
require 'minitest/autorun'
require 'flexmock/minitest'

module XmlConv
	module Conversion
		def const_get(symbol)
			if(symbol.is_a?(FlexMock))
				symbol
			else
				super
			end
		end
		module_function :const_get
	end
	module Util
		class TestApplication < ::Minitest::Test
			def setup
				@app = Util::Application.new
				@app.init
			end
			def test_attr_readers
				assert_respond_to(@app, :transactions)
				assert_respond_to(@app, :failed_transactions)
			end
			def test_execute
				transaction = flexmock('Transaction')
				cache = flexmock('Cache')
        cache.should_receive(:transaction).with(Proc).once.and_return{ |block|  block.call }
        cache.should_receive(:store).with(@app.transactions)
				ODBA.cache = cache
        transaction.should_receive(:transaction_id=).with(1)
        transaction.should_receive(:execute).once.and_return(transaction)
        transaction.should_receive(:postprocess).once
        transaction.should_receive(:error=).never
        transaction.should_receive(:odba_store).once
        transaction.should_receive(:notify).once
				assert_equal([], @app.transactions)
				assert_equal(0, @app.transactions.size)
				@app.execute(transaction)
				assert_equal([transaction], @app.transactions)
			ensure
				ODBA.cache = nil
			end
			def test_execute__survive_notification_failure
				transaction = flexmock('Transaction')
				cache = flexmock('Cache')
        cache.should_receive(:transaction).with(Proc).once.and_return{ |block|  block.call }
        cache.should_receive(:store).with(@app.transactions)
				ODBA.cache = cache
        transaction.should_receive(:transaction_id=).with(1)
        transaction.should_receive(:execute).once.and_raise(Net::SMTPFatalError, 'could not send email')
        transaction.should_receive(:postprocess).never
        transaction.should_receive(:error=).never
        transaction.should_receive(:odba_store).once
				assert_equal([], @app.transactions)
				assert_equal(0, @app.transactions.size)
				@app.execute(transaction)
				assert_equal([transaction], @app.transactions)
			ensure
				ODBA.cache = nil
			end
			def test_execute__notify_errors
				transaction = flexmock('Transaction')
				cache = flexmock('Cache')
        cache.should_receive(:transaction).with(Proc).once.and_return{ |block|  block.call }
        cache.should_receive(:store).with(@app.transactions)
				ODBA.cache = cache
        transaction.should_receive(:transaction_id=).with(1)
        transaction.should_receive(:execute).and_raise 'oops, something went wrong'
        transaction.should_receive(:postprocess).never
        transaction.should_receive(:error=).once
        transaction.should_receive(:odba_store).once
        transaction.should_receive(:notify).once
				assert_equal([], @app.transactions)
				assert_equal(0, @app.transactions.size)
				@app.execute(transaction)
				assert_equal([transaction], @app.transactions)
			ensure
				ODBA.cache = nil
			end
			def test_dumpable
				assert_raises(TypeError) { Marshal.dump(@app) }
			end
			def test_next_transaction_id
				assert_equal([], @app.transactions)
				assert_equal(1, @app.next_transaction_id)
				assert_equal(2, @app.next_transaction_id)
				assert_equal(3, @app.next_transaction_id)
				trans1 = flexmock('Transaction1')
				trans2 = flexmock('Transaction2')
        trans1.should_receive(:transaction_id).and_return(6)
        trans2.should_receive(:transaction_id).and_return(3)
				@app.transactions.push(trans1)
				@app.transactions.push(trans2)
				@app.instance_variable_set('@next_transaction_id', nil)
				assert_equal(7, @app.next_transaction_id)
			end
			def test_odba_exclude_vars
				@app.instance_variable_set('@next_transaction_id', 10)
				@app.instance_eval('odba_replace_excluded!')
				assert_nil(@app.instance_variable_get('@next_transaction_id'))
			end
			def test_transaction
				trans1 = flexmock('Transaction1')
				trans2 = flexmock('Transaction2')
				trans3 = flexmock('Transaction2')
        trans1.should_receive(:transaction_id).and_return(1).at_least.once
        trans2.should_receive(:transaction_id).and_return(2).at_least.once
        trans3.should_receive(:transaction_id).and_return(5).at_least.once
				@app.transactions.push(trans1)
				@app.transactions.push(trans2)
				assert_equal(trans1, @app.transaction(1))
				@app.transactions.push(trans3)
				assert_equal(trans2, @app.transaction(2))
				assert_equal(trans3, @app.transaction(5))
				assert_equal(trans3, @app.transaction('5'))
			end
      def test_exprort_orders
        transaction = flexmock('transaction') do |trans|
          trans.should_receive(:commit_time).and_return(Time.local(2010,1,1))
          trans.should_receive(:output).and_return('output')
        end
        @app.transactions.push(transaction)
        temp = Tempfile.new('test_export_order')
        assert_equal([transaction], @app.export_orders(Time.local(2009,1,1), Time.local(2011,1,1), temp.path))
        temp.close
     end
		end
	end
end
