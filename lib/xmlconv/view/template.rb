#!/usr/bin/env ruby
# View::Template -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/divtemplate'
require 'xmlconv/view/foot'

module XmlConv
  module View
    class Template < HtmlGrid::DivTemplate
      HTTP_HEADERS = {
        'Content-Type' => 'text/html;charset=UTF-8'
      }
      META_TAGS = [{
        'http-equiv' => 'content-type',
        'content'    => 'tex/html;charset=UTF-8'
      }]
      COMPONENTS = {
        [0, 0] => :content,
        [0, 1] => :foot,
      }
      FOOT = Foot
    end
  end
end
