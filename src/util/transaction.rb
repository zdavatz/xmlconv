#!/usr/bin/env ruby
# Util::Transaction -- xmlconv2 -- 04.06.2004 -- hwyss@ywesee.com

require 'odba'
require 'conversion/bdd_geh'
require 'conversion/bdd_i2'
require 'conversion/bdd_xml'
require 'conversion/geh_bdd'
require 'conversion/i2_bdd'
require 'conversion/xml_bdd'
require 'util/destination'
require 'net/smtp'
require 'tmail'

module XmlConv
	module Util
		class Transaction
			include ODBA::Persistable
			MAIL_FROM = 'xmlconv@ywesee.com'
			SMTP_HANDLER = Net::SMTP
			attr_accessor :input, :reader, :writer, :destination, :origin, 
										:transaction_id, :error, 
										:error_recipients, :debug_recipients
			attr_reader :output, :model, :start_time, :commit_time, 
									:input_model, :output_model, :status
			def execute
				reader_instance = Conversion.const_get(@reader)
				writer_instance = Conversion.const_get(@writer)
				@start_time = Time.now
				input_model = reader_instance.parse(@input)
				@model = reader_instance.convert(input_model)
				output_model = writer_instance.convert(@model)
				@output = output_model.to_s
				@destination.deliver(output_model)
				@commit_time = Time.now
				@output
			ensure
				@destination.forget_credentials!
			end
			def notify
				recipients = [@debug_recipients]
				subject = 'XmlConv2 - Debug-Notification'
				if(@error)
					recipients.push(@error_recipients)
					subject = 'XmlConv2 - Error-Notification'
				end
				recipients.flatten!
				recipients.compact!
				recipients.uniq!
				return if(recipients.empty?)
				mail = TMail::Mail.new
				mail.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
				mail.body = <<-EOS
Date:   #{@start_time.strftime("%d.%m.%Y")}
Time:   #{@start_time.strftime("%H:%M:%S")}
Status: #{status}
Error:  #{@error}
Link:   http://janico.ywesee.com/de/transaction/transaction_id/#{@transaction_id}

Input:
# input start
#{@input}
# input end

Output:
# output start
#{@output}
# output end
				EOS
				mail.from = self::class::MAIL_FROM
				mail.to = recipients
				mail.subject = subject
				mail.date = Time.now
				mail['User-Agent'] = 'XmlConv::Util::Transaction'

				self.class::SMTP_HANDLER.start('mail.ywesee.com') { |smtp|
					smtp.sendmail(mail.encoded, self::class::MAIL_FROM, recipients)
				}
			end
			def status
				if(@error)
					:error
				elsif(@destination.respond_to?(:status))
					@destination.status
				end
			end
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
