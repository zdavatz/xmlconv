#!/usr/bin/env ruby
# Session -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/session'
require 'xmlconv/state/login'
require 'xmlconv/custom/lookandfeel'
require 'xmlconv/util/known_user'

module XmlConv
	module Util
		class Session < SBSM::Session
			DEFAULT_LANGUAGE = 'de'
			DEFAULT_STATE = State::Login
			LOOKANDFEEL = Custom::Lookandfeel
			def login
				if((pass = user_input(:pass)) \
					&& (pass == XMLConv::CONFIG.pass_hash))
					@user = Util::KnownUser.new
				end
			end
		end
	end
end
