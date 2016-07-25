#!/usr/bin/env ruby
# View::Preformatted -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/value'

module XmlConv
  module View
    class Preformatted < HtmlGrid::Value
      BREAK_WIDTH = 65

      def init
        super
        if @value
          raw = @value.gsub(/>\s+</, '><').gsub(/\t|\r\n?/, '')
          # fix encoding
          if raw =~ /ISO\-8859\-1|WINDOWS\-1252/i
            raw.force_encoding(Encoding::ISO_8859_1)
          end
          raw.encode!(Encoding::UTF_8).force_encoding(Encoding::UTF_8)
          @value = <<~PRE
            <pre>#{
              cgi_with_utf8 {
                # prettify (indent)
                pretty = begin CGI.pretty(raw); rescue raw; end
                # omit tags
                CGI.escapeHTML(wrap(pretty))
              }
            }</pre>
          PRE
        end
      end

      private

      def wrap(pretty)
        wrapped = ''
        pretty.each_line { |line|
          if line.length < BREAK_WIDTH
            wrapped << line
          else
            indent = line[/^ +/].to_s
            indent = indent[0,indent.length % (BREAK_WIDTH / 3)]
            tmpparts = line.split(/(?<=") +(?=")/)
            parts = []
            tmpparts.each { |part|
              if part.length > BREAK_WIDTH
                parts.concat(part.split(/ /))
              else
                parts.push(part)
              end
            }
            wrapline = parts.shift
            while part = parts.shift
              if (wrapline.length + part.length) >= BREAK_WIDTH
                wrapped << wrapline
                wrapped << "\n"
                wrapline = indent.dup << (' ' * 5) << part
              else
                wrapline << ' ' << part
              end
            end
            wrapped << wrapline
          end
        }
        wrapped
      end

      def cgi_with_utf8
        orig_verbose = $VERBOSE
        $VERBOSE = nil
        result = yield
        $VERBOSE = orig_verbose
        result
      end
    end
  end
end
