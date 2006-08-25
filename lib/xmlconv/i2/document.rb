#!/usr/bin/env ruby
# I2::Document -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'xmlconv/i2/header'
require 'xmlconv/i2/order'

module XmlConv
	module I2
		class Document
			attr_accessor :header
			attr_reader :orders
			def initialize
        @header = Header.new
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
