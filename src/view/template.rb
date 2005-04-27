#!/usr/bin/env ruby
# View::Template -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/template'
require 'view/foot'
#require 'view/head'

module XmlConv
	module View
		class Template < HtmlGrid::Template
			COMPONENTS = {
				#[0,0]	=>	:head,
				[0,0]	=>	:content,
				[0,1]	=>	:foot,
			}
			#CSS_CLASS = 'template'
			FOOT = Foot
			#HEAD = Head
		end
	end
end
