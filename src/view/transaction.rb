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
				[0,2]	=>	'th_error',
				[0,3]	=>	:error_string,
			}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0,2]	=>	'th',
				[0,1,2]	=>	'helfti preformatted',
				[0,2]		=>	'th',
				[0,3]		=>	'list preformatted bg',
			}
			COLSPAN_MAP = {
				[0,2]	=>	2,
				[0,3]	=>	2,
			}
			DEFAULT_CLASS = View::Preformatted
			LEGACY_INTERFACE = false
			def error_string(model)
				if(err = model.error)
					[err.class, err.message, err.backtrace].join("\n")
				end
			end
		end
		class Transaction < Template
			CONTENT = TransactionComposite
		end
	end
end
