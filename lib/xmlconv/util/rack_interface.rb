#!/usr/bin/env ruby

require 'date'
require 'sbsm/app'

module XmlConv
  module Util
    class RackInterface < SBSM::RackInterface
      ENABLE_ADMIN = true
      SESSION = XmlConv::Util::Session
      VALIDATOR = XmlConv::Util::Validator
      def initialize(app: XmlConvApp,
                     auth: nil,
                     validator: XmlConv::Util::Validator)
        [ File.join(Dir.pwd, 'etc', 'config.yml'),
        ].each do |config_file|
          if File.exist?(config_file)
            SBSM.info "XmlConv.config.load from #{config_file}"
            XmlConv.config.load (config_file)
            break
          end
        end
        @app = app
        super(app: app,
              session_class: XmlConv::Util::Session,
              unknown_user: XmlConv::Util::KnownUser.new,
              validator: validator,
              cookie_name: 'virbac.bbmb'
              )
      end
    end
  end
end
