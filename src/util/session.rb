#!/usr/bin/env ruby
# Session -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/session'
require 'state/login'
require 'custom/lookandfeel'
require 'util/known_user'

module XmlConv
	module Util
		class Session < SBSM::Session
			DEFAULT_LANGUAGE = 'de'
			DEFAULT_STATE = State::Login
			LOOKANDFEEL = Custom::Lookandfeel
			def login
				if((pass = user_input(:pass)) \
					&& (pass == "6646c9e7892ef147dbed611a00ea48e6"))
					@user = Util::KnownUser.new
				end
			end
		end
	end
end
