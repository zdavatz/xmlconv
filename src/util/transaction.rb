#!/usr/bin/env ruby
# Util::Transaction -- xmlconv2 -- 04.06.2004 -- hwyss@ywesee.com

require 'odba'
require 'conversion/bdd_i2'
require 'conversion/bdd_xml'
require 'conversion/i2_bdd'
require 'conversion/xml_bdd'
require 'util/destination'

module XmlConv
	module Util
		class Transaction
			include ODBA::Persistable
			attr_accessor :input, :reader, :writer, :destination, :origin, 
										:transaction_id, :error
			attr_reader :output, :model, :start_time, :commit_time, 
									:input_model, :output_model, :status
			def execute
				reader_instance = Conversion.const_get(@reader)
				writer_instance = Conversion.const_get(@writer)
				input_model = reader_instance.parse(@input)
				@start_time = Time.now
				@model = reader_instance.convert(input_model)
				output_model = writer_instance.convert(@model)
				@commit_time = Time.now
				@destination.deliver(output_model)
				@output = output_model.to_s
			ensure
				@destination.forget_credentials!
			end
			def status
				@destination.status if(@destination.respond_to?(:status))
			end
			attr_accessor :transaction_id
			def status_comparable
				if(@destination.respond_to?(:status_comparable))
					@destination.status_comparable 
				end
			end
			def update_status
				if(@destination.respond_to?(:update_status))
					@destination.update_status 
				end
			end
			def uri
				@destination.uri if(@destination.respond_to?(:uri))
			end
			def uri_comparable
				self.uri.to_s
			end
		end
	end
end
