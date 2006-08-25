#!/usr/bin/env ruby
# View::Login -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'xmlconv/view/template'
require 'htmlgrid/form'
require 'htmlgrid/pass'

module XmlConv
	module View
		class LoginForm < HtmlGrid::Form
			COMPONENTS = {
				[0,0]	=>	:pass,
				[1,1]	=>	:submit,
			}
			CSS_CLASS = 'component'
			EVENT = :login
			LABELS = true
			SYMBOL_MAP = {
				:pass =>  HtmlGrid::Pass,
			}
		end
		class LoginComposite < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	"login_welcome",
				[0,1]	=>	LoginForm,
			}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0]	=>	'th',
			}
		end
		class Login < Template
			CONTENT = LoginComposite
		end
	end
end
