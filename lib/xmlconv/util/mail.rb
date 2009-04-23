#!/usr/bin/env ruby
# Util::Mail -- XmlConv -- 23.04.2009 -- hwyss@ywesee.com

require 'net/smtp'
require 'tmail'
require 'xmlconv/config'

module XmlConv
  module Util
module Mail
  SMTP_HANDLER = Net::SMTP
  def Mail.notify recipients, subject, body
    recipients.flatten!
    recipients.compact!
    recipients.uniq!
    return if(recipients.empty?)
    mail = TMail::Mail.new
    mail.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
    mail.body = body
    mail.from = XmlConv::CONFIG.mail_from
    mail.to = recipients
    mail.subject = subject
    mail.date = Time.now
    mail['User-Agent'] = 'XmlConv::Util::Mail'
    SMTP_HANDLER.start(XmlConv::CONFIG.mail_host) { |smtp|
      smtp.sendmail(mail.encoded, XmlConv::CONFIG.mail_from, recipients)
    }
  end
end
  end
end
