#!/usr/bin/env ruby
# Model::Item -- xmlconv2 -- 23.06.2004 -- hwyss@ywesee.com

require 'xmlconv/model/id_container'
require 'xmlconv/model/freetext_container'
require 'xmlconv/model/part_info_container'
require 'xmlconv/model/price_container'

module XmlConv
	module Model
		class Item
			attr_accessor :line_no, :qty, :unit
			include IdContainer
			include FreeTextContainer
			include PartInfoContainer
			include PriceContainer
		end
	end
end
