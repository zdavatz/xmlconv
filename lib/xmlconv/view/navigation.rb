#!/usr/bin/env ruby
# View::Navigation -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/composite'
require 'xmlconv/view/navigationlink'

module XmlConv
	module View
		class Navigation < HtmlGrid::Composite
			COMPONENTS = {}
			CSS_CLASS = "navigation"
			#HTML_ATTRIBUTES = {"align"=>"right"}
			SYMBOL_MAP = {
				:navigation_divider =>  HtmlGrid::Text,
			}
			def init
				build_navigation()
				super
			end
			def build_navigation
				@lookandfeel.navigation.each_with_index { |state, idx|
					evt = state.is_a?(Symbol) ? state : state.direct_event
					symbol_map.store(evt, NavigationLink)
					components.store([idx*2,0], evt)
					components.store([idx*2-1,0], :navigation_divider) if(idx > 0)
				}
			end
		end
	end
end
