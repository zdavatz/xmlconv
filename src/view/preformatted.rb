#!/usr/bin/env ruby
# View::Preformatted -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/value'

module XmlConv
	module View
		class Preformatted < HtmlGrid::Value
			def init
				super
				@value.gsub!(/>\s*</, "><")
				@value = CGI.pretty(@value)
				@value = CGI.escapeHTML(@value)
			end
			def to_html(context)
				context.pre { super }
			end
		end
	end
end
