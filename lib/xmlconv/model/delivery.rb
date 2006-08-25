#!/usr/bin/env ruby
# Delivery -- xmlconv -- 01.06.2004 -- hwyss@ywesee.com

require 'xmlconv/model/transaction'

module XmlConv
	module Model
		class Delivery < Transaction
			attr_accessor :bsr, :delivery_date
			def bsr_id
				@bsr.bsr_id unless(@bsr.nil?)
			end
		end
	end
end
