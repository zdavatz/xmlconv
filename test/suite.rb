#!/usr/bin/env ruby
# TestSuite -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(File.expand_path(__FILE__))

Dir.foreach(File.dirname(__FILE__)) { |file|
	if /^test_.*\.rb$/o.match(file)
		require file 
	end
}
