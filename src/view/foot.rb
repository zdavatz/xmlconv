#!/usr/bin/env ruby
# View::Foot -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/composite'
require 'view/navigation'

module XmlConv
	module View
		class Foot < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	Navigation,
			}
			CSS_CLASS = 'foot composite'
			LEGACY_INTERFACE = false
		end
	end
end
