#!/usr/bin/env ruby
# View::Transaction -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/value'
require 'view/template'
require 'view/preformatted'

module XmlConv
	module View
		class TransactionComposite < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	'th_input',
				[1,0]	=>	'th_output',
				[0,1]	=>	:input,
				[1,1]	=>	:output,
			}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0,2]	=>	'th',
				[0,1,2]	=>	'helfti',
			}
			DEFAULT_CLASS = View::Preformatted
			LEGACY_INTERFACE = false
			def init
				if(@model.error)
					components.store([0,2], :error_string)
					colspan_map.store([0,2], 2)
				end
				super
			end
		end
		class Transaction < Template
			CONTENT = TransactionComposite
		end
	end
end
