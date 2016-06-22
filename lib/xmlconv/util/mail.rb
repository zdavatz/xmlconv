#!/usr/bin/env ruby
# Util::Mail -- XmlConv -- 23.04.2009 -- hwyss@ywesee.com

require 'net/smtp'
unless /^1\.8/.match(RUBY_VERSION)
  require 'mail'
end

require 'xmlconv/config'

module XmlConv
  module Util
module Mail
  SMTP_HANDLER = Net::SMTP
  def Mail.notify recipients, my_subject, my_body
    unless /^1\.8/.match(RUBY_VERSION)
      puts "XmlConv::Util::Mail.notify #{ XmlConv::CONFIG.mail_from} -> #{recipients} subject: #{my_subject}"
      puts "Skipping as RUBY_VERSON is #{RUBY_VERSION}"
      return
    end
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
  end
end
  end
end
