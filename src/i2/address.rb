#!/usr/bin/env ruby
# I2::Address -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

module XmlConv
	module I2
		class Address
			attr_accessor :code, :party_id
			attr_accessor :name1, :name2, :street1, :city, :zip_code, :street2
			I2_ADDR_CODES = {
				:buyer		=>	'BY',
				:delivery	=>	'DP',
				:employee	=>	'EP',
			}
			def initialize
				@code = :buyer
			end
			def to_s
				output = []
				numerals = [ 201, 202, 220, 221, 222, 223, 225, 226 ]
				[
					I2_ADDR_CODES[@code],
					@party_id, @name1, @name2, @street1,
					@city, @zip_code, @street2,
				].each_with_index { |value, idx|
					unless(value.nil?)
						output << "#{numerals[idx]}:#{value}"
					end
				}
				output.join("\n") << "\n"
			end
		end
	end
end
