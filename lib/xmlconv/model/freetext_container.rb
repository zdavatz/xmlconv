#!/usr/bin/env ruby
# FreeTextContainer -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class FreeText < String
			attr_accessor :type
			def <<(other)
				if(empty? || other.empty?)
					super
				else
					super("\n" << other)
				end
			end
		end
		module FreeTextContainer
			attr_accessor :free_text
			def add_free_text(type, text)
				@free_text ||= FreeText.new
				@free_text.type = type
				@free_text << text.to_s
				@free_text
			end
		end
	end
end
