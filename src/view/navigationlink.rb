#!/usr/bin/env ruby
# View::NavigationLink -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/link'

module XmlConv
	module View
		class NavigationLink < HtmlGrid::Link
			#CSS_CLASS = "navigation"
			def init
				super
				unless(@lookandfeel.direct_event == @name)
					@attributes.store("href", @lookandfeel.event_url(@name))
				end
			end
		end
	end
end



