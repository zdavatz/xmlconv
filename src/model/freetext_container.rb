#!/usr/bin/env ruby
# FreeTextContainer -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class FreeText < String
			attr_accessor :type
		end
		module FreeTextContainer
			def add_free_text(type, text)
				freetext = FreeText.new
				freetext.type = type
				freetext << text.to_s
				self.free_texts.push(freetext)
			end
			def free_texts
				@free_texts ||= []
			end
		end
	end
end
