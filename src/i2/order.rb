#!/usr/bin/env ruby
# I2::Order -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

module XmlConv
	module I2
		class Order
			attr_accessor :sender_id, :delivery_id
			attr_reader :addresses, :dates, :positions
			def initialize
				@addresses = []
				@dates = []
				@positions = []
			end
			def add_address(address)
				@addresses.push(address)
			end
			def add_date(date)
				@dates.push(date)
			end
			def add_position(position)
				@positions.push(position)
			end
			def to_s
				output = <<-EOS
100:#{@sender_id}
101:#{@delivery_id}
				EOS
				@addresses.each { |addr| output << addr.to_s }
				output << "237:61\n"
				@dates.each { |date| output << date.to_s }
				@positions.each { |pos| output << pos.to_s }
				output
			end
		end
	end
end
