#!/usr/bin/env ruby
# Config -- xmlconv2 -- 21.08.2006 -- hwyss@ywesee.com

require 'ostruct'

module XmlConv
  CONFIG = OpenStruct.new
  CONFIG.grammar_dir = File.expand_path('../data/grammar', 
                                        File.dirname(__FILE__))
  CONFIG.polling_file = File.expand_path('data/polling.yaml',
                                         File.dirname(__FILE__))
end
