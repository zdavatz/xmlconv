#!/usr/bin/env ruby
# I2::Parser -- xmlconv2 -- 28.06.2004 -- hwyss@ywesee.com

require 'rockit/rockit'

module XmlConv
	module I2
		def cached_parser
			grammar_path = File.expand_path('i2.grammar', CONFIG.grammar_dir)
			parser_path = File.expand_path('i2_parser.rb', CONFIG.grammar_dir)
			old_path = File.expand_path('i2.grammar.old', CONFIG.grammar_dir)
			src = File.read(grammar_path)
			unless(File.exists?(old_path) && File.read(old_path) == src)
				File.delete(old_path) if File.exists?(old_path)
				Parse.generate_parser_from_file_to_file(grammar_path, parser_path, "make_i2_parser", 'XmlConv')
				File.open(old_path, 'w') { |f| f << src }
			end
			require parser_path
			XmlConv.make_i2_parser
		end
		module_function :cached_parser
	end
end
