#!/usr/bin/env ruby
# DeliveryItem -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'model/item'

module XmlConv
	module Model
		class DeliveryItem < Item
			attr_accessor :delivery_date
			def et_nummer_id
				self.ids['ET-NUMMER']
			end
		end
	end
end
