#!/usr/bin/env ruby
# Model::ItemContainer -- xmlconv2 -- 22.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		module ItemContainer
			def add_item(item)
				self.items.push(item)
			end
			def items
				@items ||= []
			end
		end
	end
end
