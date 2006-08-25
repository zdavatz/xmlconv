#!/usr/bin/env ruby
# Model::PartInfoContainer -- xmlconv2 -- 23.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		module PartInfoContainer
			def add_part_info(info)
				self.part_infos.push(info)
			end
			def part_infos
				@part_infos ||= []
			end
		end
	end
end
