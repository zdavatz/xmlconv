#!/usr/bin/env ruby
# Name -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class Name
			attr_accessor :first, :last
			def to_s
				[@first, @last].compact.join(' ')
			end
		end
	end
end
