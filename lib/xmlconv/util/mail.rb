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
    config = XmlConv::CONFIG
    if config.mail_suppress_sending
      puts "#{__FILE__}:#{__LINE__} Suppress sending mail with subject: #{my_subject}"
      ::Mail.defaults do  delivery_method :test end
    else
      puts "Mail.sendmail #{config.smtp_server} #{config.smtp_port} smtp_user: #{config.smtp_user} subject #{my_subject}"
      ::Mail.defaults do
      options = { :address              => config.smtp_server,
                  :port                 => config.smtp_port,
                  :domain               => config.smtp_domain,
                  :user_name            => config.smtp_user,
                  :password             => config.smtp_pass,
                  :authentication       => 'plain',
                  :enable_starttls_auto => true  }
        delivery_method :smtp, options
      end
    end
    recipients.flatten!
    recipients.compact!
    recipients.uniq!
    return if(recipients.empty?)
    mail = ::Mail.deliver do
      from  (config.mail_from || 'dummy@test.com')
      to recipients
      subject my_subject
      body my_body
    end
  end
end
  end
end
