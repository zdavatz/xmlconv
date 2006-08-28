#!/usr/bin/env ruby
# Util#autoload -- xmlconv2 -- 28.08.2006 -- hwyss@ywesee.com

module XmlConv
  module Util
    def Util.autoload(dir, type)
      config = XmlConv::CONFIG
      logger = XmlConv::LOGGER
      dir = File.expand_path(dir)
      prefix = File.basename(dir)
      search_path = File.dirname(dir)
      $:.push(search_path) unless $:.include?(search_path)
      logger.debug(config.program_name) { 
        "checking directory '#{dir}' for #{type}s" 
      }
      Dir.glob(File.join(dir, '*')) { |entry|
        if(/\.(rb|so)$/.match(entry))
          keyword = File.basename(entry)
          keyword.slice!(/#{File.extname(keyword)}$/)
          rpath = File.join(prefix, keyword)
          logger.debug(config.program_name) { 
            "loading #{type}: '#{rpath}' (#{File.basename(entry)})" 
          }
          begin
            require rpath #File.basename(keyword)
          rescue 
            logger.warn(config.program_name) {
              "loading #{type} '#{rpath}' failed!"
            }
          end
        end
      }
    end
  end
end
