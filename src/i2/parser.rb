#!/usr/bin/env ruby
# I2::Parser -- xmlconv2 -- 28.06.2004 -- hwyss@ywesee.com

require 'rockit/rockit'

module XmlConv
	module I2
		GRAMMAR_DIR = File.expand_path('../../data/grammar', 
			File.dirname(__FILE__))
		def cached_parser
			grammar_path = File.expand_path('i2.grammar', GRAMMAR_DIR)
			parser_path = File.expand_path('i2_parser.rb', GRAMMAR_DIR)
			old_path = File.expand_path('i2.grammar.old', GRAMMAR_DIR)
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
