#!/usr/bin/env ruby
# DeliveryItem -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

require 'model/id_container'
require 'model/freetext_container'
require 'model/price_container'

module XmlConv
	module Model
		class DeliveryItem
			attr_accessor :line_no, :qty, :delivery_date
			attr_reader :et_nummer_id
			include IdContainer
			include FreeTextContainer
			include PriceContainer
		end
	end
end
