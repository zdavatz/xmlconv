#!/usr/bin/env ruby
# IdContainer -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		module IdContainer
			def add_id(domain, value)
				self.ids.store(domain, value)
			end
			def ids
				@ids ||= {}
			end
		end
	end
end
