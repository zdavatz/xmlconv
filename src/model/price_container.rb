#!/usr/bin/env ruby
# PriceContainer -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		module PriceContainer
			def add_price(price)
				@prices.push(price)
			end
			def prices
				@prices ||= []
			end
		end
	end
end
