#!/usr/bin/env ruby
# Util::TestTransaction -- xmlconv2 -- 04.06.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'xmlconv/util/transaction'
require 'mail'
require 'minitest/autorun'
require 'flexmock/minitest'

Mail.defaults do
  delivery_method :test
end

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
		class TestTransaction < ::Minitest::Test
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
				src = flexmock('source')
				input = flexmock('input')
				reader = flexmock('reader')
				model = flexmock('model')
				writer = flexmock('writer')
				output = flexmock('output')
				destination = flexmock('destination')
				@transaction.input = src
				@transaction.reader = reader
				@transaction.writer = writer
				@transaction.destination = destination
        reader.should_receive(:parse).with(src).once.and_return(input)
        reader.should_receive(:convert).with(input).once.and_return(model)
        writer.should_receive(:convert).with(model).once.and_return(output)
        destination.should_receive(:deliver).with(output).once
        destination.should_receive(:forget_credentials!).once
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
			end
			def test_persistable
				assert_kind_of(ODBA::Persistable, @transaction)
			end
			def test_dumpable
				Marshal.dump(@transaction)
			end
			def test_notify
          ::Mail::TestMailer.deliveries.clear
          ::Mail.defaults do
          delivery_method :test
        end
				@transaction.instance_variable_set('@start_time', Time.now)
				@transaction.error_recipients = ['bar']
				@transaction.notify
        assert_equal(0, ::Mail::TestMailer.deliveries.size)
				@transaction.debug_recipients = ['foo']
				@transaction.notify
        assert_equal(1, ::Mail::TestMailer.deliveries.size)
        assert_equal(['foo'], ::Mail::TestMailer.deliveries.last.to)
				@transaction.error = 'error!'
				@transaction.notify
        assert_equal(2, ::Mail::TestMailer.deliveries.size)
        assert_equal(['foo', 'bar'], ::Mail::TestMailer.deliveries.last.to)
			end
		end
	end
end
