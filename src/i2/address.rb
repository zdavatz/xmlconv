#!/usr/bin/env ruby
# I2::Address -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

module XmlConv
	module I2
		class Address
			attr_accessor :code, :buyer_id
			attr_accessor :name1, :name2, :street1, :city, :zip_code, :street2
			def initialize
				@code = :buyer
			end
			def to_s
				if(@code == :delivery)
					<<-EOS
201:DP
220:#{@name1}
221:#{@name2}
222:#{@street1}
223:#{@city}
225:#{@zip_code}
226:#{@street2}
					EOS
				else
					<<-EOS
201:BY
202:#{@buyer_id}
					EOS
				end
			end
		end
	end
end
