#!/usr/bin/env ruby
# IdContainer -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		module IdContainer
			attr_reader :ids
			def add_id(domain, value)
				self.ids.store(domain, value)
				if(domain && !domain.empty?)
					var = domain.gsub(/-/, '_').downcase
					instance_variable_set("@#{var}_id", value)
				end
			end
			def ids
				@ids ||= {}
			end
		end
	end
end
