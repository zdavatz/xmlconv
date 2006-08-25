#!/usr/bin/env ruby
# Name -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class Name
			attr_reader :first, :last, :text
			def first=(arg)
				set_attr('@first', arg && arg.strip)
			end
			def last=(arg)
				set_attr('@last', arg && arg.strip)
			end
			def text=(arg)
				set_attr('@text', arg && arg.strip)
			end
			def to_s
				[@first, @text, @last].compact.join(' ')
			end
			private
			def set_attr(attr, arg)
				str = arg.to_s
				instance_variable_set(attr, str.empty? ? nil : str)
			end
		end
	end
end
