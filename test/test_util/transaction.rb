#!/usr/bin/env ruby
# Util::TestTransaction -- xmlconv2 -- 04.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/transaction'
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
		class TestTransaction < Test::Unit::TestCase
			def setup
				@transaction = Util::Transaction.new
			end
			def test_attr_accessors
				assert_respond_to(@transaction, :input)
				assert_respond_to(@transaction, :input=)
				assert_respond_to(@transaction, :reader)
				assert_respond_to(@transaction, :reader=)
				assert_respond_to(@transaction, :writer)
				assert_respond_to(@transaction, :writer=)
				assert_respond_to(@transaction, :transaction_id)
				assert_respond_to(@transaction, :transaction_id=)
				assert_respond_to(@transaction, :error)
				assert_respond_to(@transaction, :error=)
			end
			def test_attr_readers
				assert_respond_to(@transaction, :output)
				assert_respond_to(@transaction, :model)
				assert_respond_to(@transaction, :start_time)
				assert_respond_to(@transaction, :commit_time)
			end
			def test_execute
				src = Mock.new('source')
				input = Mock.new('input')
				reader = Mock.new('reader')
				model = Mock.new('model')
				writer = Mock.new('writer')
				output = Mock.new('output')
				destination = Mock.new('destination')
				@transaction.input = src
				@transaction.reader = reader
				@transaction.writer = writer
				@transaction.destination = destination
				reader.__next(:parse) { |read_src|
					assert_equal(src, read_src)
					input	
				}
				reader.__next(:convert) { |read_input|
					assert_equal(input, read_input)
					model
				}
				writer.__next(:convert) { |write_input|
					assert_equal(model, write_input)
					output
				}
				destination.__next(:deliver) { |delivery|
					assert_equal(output, delivery)
				}
				destination.__next(:forget_credentials!) { }
				time1 = Time.now
				result = @transaction.execute
				time2 = Time.now
				assert_equal(src, @transaction.input)
				assert_equal(reader, @transaction.reader)
				assert_equal(model, @transaction.model)
				assert_equal(writer, @transaction.writer)
				assert_equal(output.to_s, @transaction.output)
				assert_equal(output.to_s, result)
				assert_in_delta(time1, @transaction.start_time, 0.001)
				assert_in_delta(time2, @transaction.commit_time, 0.001)
				input.__verify
				reader.__verify
				model.__verify
				writer.__verify
				output.__verify
				destination.__verify
			end
			def test_persistable
				assert_kind_of(ODBA::Persistable, @transaction)
			end
			def test_dumpable
				assert_nothing_raised { Marshal.dump(@transaction) }
			end
		end
	end
end
