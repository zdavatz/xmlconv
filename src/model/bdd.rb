#!/usr/bin/env ruby
# Bdd -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class Bdd
			attr_accessor :bsr
			attr_reader :deliveries
			def initialize
				@deliveries = []
			end
			def add_delivery(delivery)
				@deliveries.push(delivery)
			end
		end
	end
end
