#!/usr/bin/env ruby
# XmlConv::Config -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

require 'odba'
require 'etc/access'

module XmlConv
	SERVER_URI = 'druby://localhost:10010'
end
class XmlConvApp
	ENABLE_ADMIN = true
end

ODBA.storage.dbi = DBI.connect('DBI:pg:xmlconv2', 'xmlconv2', '2fh9dojs')
