#!/usr/bin/env ruby
# index.rbx -- xmlconv2 -- hwyss@ywesee.com

require 'sbsm/request'
require 'etc/config'

DRb.start_service()
begin
	SBSM::Request.new(XmlConv::SERVER_URI).process
rescue Exception => e
	$stderr << "XmlConv-Client-Error: " << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
