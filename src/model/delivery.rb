#!/usr/bin/env ruby
# Delivery -- xmlconv -- 01.06.2004 -- hwyss@ywesee.com

require 'model/transaction'

module XmlConv
	module Model
		class Delivery < Transaction
			attr_accessor :bsr
			def bsr_id
				@bsr.bsr_id unless(@bsr.nil?)
			end
			def customer_id
				self.ids['Customer']
			end
			def reference_id
				self.ids['ACC']
			end
		end
	end
end
