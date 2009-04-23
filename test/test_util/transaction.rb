#!/usr/bin/env ruby
# Util::TestTransaction -- xmlconv2 -- 04.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/transaction'
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
    module Mail
      SMTP_HANDLER = Mock.new('SMTP-Handler')
    end
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
			def test_notify
				@transaction.instance_variable_set('@start_time', Time.now)
				@transaction.error_recipients = ['bar']
				smtp = Mail::SMTP_HANDLER
				@transaction.notify
				@transaction.debug_recipients = ['foo']
				mail = Mock.new('MailSession')
				mail.__next(:sendmail) { |encoded, from, recipients| 
					assert_equal(['foo'], recipients)
				
				}
				smtp.__next(:start) { |block, server|
					block.call(mail)
				}
				@transaction.notify
				@transaction.error = 'error!'
				mail.__next(:sendmail) { |encoded, from, recipients| 
					assert_equal(['foo', 'bar'], recipients)
				
				}
				smtp.__next(:start) { |block, server|
					block.call(mail)
				}
				@transaction.notify
				smtp.__verify
				mail.__verify
			end
		end
	end
end
