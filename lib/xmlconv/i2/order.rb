#!/usr/bin/env ruby
# I2::Order -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

module XmlConv
	module I2
		class Order
			I2_DELIVERY_CODES = {
        ## janico
				:pickup		  =>	'070',
				:delivery	  =>	'060',
				:camion 	  =>	'010',
        ## globopharm
        :default    =>  '1',
        :before_9   =>  '3',
        :before_21  =>  '4',
        :before_16  =>  '5',
        :extracted  =>  '13',
			}
			attr_accessor :sender_id, :delivery_id, :terms_cond, :agent, :free_text, 
        :interface, :transport_cost, :ade_id
			attr_reader :addresses, :dates, :positions
			def initialize
				@addresses = []
				@dates = []
				@positions = []
        @interface = "61"
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
        numerals = [ 231, 236, 237, 238, 242 ]
				[
					@agent, @free_text, @interface, I2_DELIVERY_CODES[@terms_cond],
          @transport_cost,
				].each_with_index { |value, idx|
					unless(value.nil?)
						output << sprintf("%s:%s\n", numerals[idx], value)
					end
				}
        if(@ade_id)
          output << sprintf("250:ADE\n251:%s\n", @ade_id)
        end
				@dates.each { |date| output << date.to_s }
				@positions.each { |pos| output << pos.to_s }
				output
			end
		end
	end
end
