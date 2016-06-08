#!/usr/bin/env ruby
# encoding: utf-8
# Util::Mail -- XmlConv -- 23.04.2009 -- hwyss@ywesee.com

require 'mail'
require 'xmlconv/config'

module XmlConv
  module Util
module Mail
  SMTP_HANDLER = Net::SMTP
  def Mail.notify recipients, my_subject, my_body
    recipients.flatten!
    recipients.compact!
    recipients.uniq!
    return if(recipients.empty?)
    mail = ::Mail.deliver do
      content_type("text/plain; charset'utf-8'")
      from(XmlConv::CONFIG.mail_from || 'dummy@test.com')
      to recipients
      subject = my_subject
      body = my_body
    end
  end
end
  end
end
