#!/usr/bin/env ruby
# TestSuite -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

$: << File.dirname(File.expand_path(__FILE__))

current_dir = File.dirname(__FILE__) 
Dir.foreach(current_dir) { |dirname|
	dirpath = File.expand_path(dirname, current_dir)
	if(/^test_/o.match(dirname) && (File.ftype(dirpath) == 'directory'))
		Dir.foreach(dirpath) { |filename|
			if(/\.rb$/o.match(filename))
				require "#{dirname}/#{filename}"
			end
		}
	end
}
