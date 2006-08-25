#!/usr/bin/env ruby
# View::Foot -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/composite'
require 'xmlconv/view/navigation'
require 'date'

module XmlConv
	module View
		class Foot < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	:copyright,
				[1,0]	=>	Navigation,
			}
			CSS_CLASS = 'foot composite'
			LEGACY_INTERFACE = false
			def copyright(model)
				link = HtmlGrid::Link.new(:copyright, model, @session, self)
				link.href = 'http://www.ywesee.com'
				link.value = @lookandfeel.lookup(:copyright, Date.today.strftime('%Y'))
				link.css_class = 'foot'
				link.target = '_blank'
				link
			end
		end
	end
end
