#!/usr/bin/env ruby
# I2::Document -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'i2/header'
require 'i2/order'

module XmlConv
	module I2
		class Document
			attr_accessor :header
			attr_reader :orders
			def initialize
				@orders = []
			end
			def add_order(order)
				@orders.push(order)
			end
			def filename
				@header.filename
			end
			def to_s
				([@header] + @orders).join
			end
		end
	end
end
