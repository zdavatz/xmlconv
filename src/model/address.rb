#!/usr/bin/env ruby
# AddressLine -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class Address
			attr_accessor :city, :zip_code
			attr_reader :lines
			def initialize
				@lines = []
			end
			def add_line(line)
				lines.push(line)
			end
		end
	end
end
