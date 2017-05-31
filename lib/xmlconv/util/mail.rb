#!/usr/bin/env ruby
# Util::Mail -- XmlConv -- 23.04.2009 -- hwyss@ywesee.com

require 'mail'
require 'xmlconv/config'

module XmlConv
  module Util
module Mail
  def Mail.notify recipients, my_subject, my_body
    recipients.flatten!
    recipients.compact!
    recipients.uniq!
    return if(recipients.empty?)
    puts "XmlConv::Util::Mail.notify #{ XmlConv::CONFIG.mail_from} -> #{recipients} subject: #{my_subject}"
    mail = ::Mail.deliver do
      from XmlConv::CONFIG.mail_from
      to recipients
      subject my_subject
      body my_body
    end
    puts "XmlConv::Util::Mail.notify failed #{mail.error_status}" if mail.error_status
  end
end
  end
end
