#!/usr/bin/env ruby
# View::Preformatted -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/value'

module XmlConv
	module View
		BREAK_WIDTH = 65
		class Preformatted < HtmlGrid::Value
      def init
        super
        pretty = ''
        if(@value)
          raw = @value.gsub(/>\s+</, "><").gsub(/\r\n?/, "\n")
          if /^<\?xml/.match(raw)
            require 'rexml/document'
            raw.scan /<\?xml.*?>(?=<\?xml|\z)/ do |part|
              doc = REXML::Document.new part
              REXML::Formatters::Pretty.new.write doc, pretty
            end
          elsif
            begin
              pretty = CGI.pretty(raw)
            rescue
              pretty = raw
            end
          end
          wrap = ''
          pretty.each_line { |line|
            if(line.length < BREAK_WIDTH)
              wrap << line
            else
              indent = line[/^ +/].to_s
              indent = indent[0,indent.length % (BREAK_WIDTH / 3)]
              tmpparts = line.split(/(?<=") +(?=")/)
              parts = []
              tmpparts.each { |part|
                if(part.length > BREAK_WIDTH)
                  parts.concat(part.split(/ /))
                else
                  parts.push(part)
                end
              }
              wrapline = parts.shift
              while(part = parts.shift)
                if((wrapline.length + part.length) >= BREAK_WIDTH)
                  wrap << wrapline
                  wrap << "\n"
                  wrapline = indent.dup << (' ' * 5) << part
                else
                  wrapline << ' ' << part
                end
              end
              wrap << wrapline
            end
          }
          @value = CGI.escapeHTML(wrap)
        end
      end
		end
	end
end
