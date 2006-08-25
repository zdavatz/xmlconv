#!/usr/bin/env ruby
# index.rbx -- xmlconv2 -- hwyss@ywesee.com

require 'sbsm/request'
require 'xmlconv/config'

DRb.start_service('druby://localhost:0')

begin
	SBSM::Request.new(XmlConv::CONFIG.server_url).process
rescue Exception => e
	$stderr << "XmlConv-Client-Error: " << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
