#!/usr/bin/env ruby
# State::Login -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/state'
require 'xmlconv/view/login'
require 'xmlconv/state/transactions'

module XmlConv
	module State
		class Login < SBSM::State
			VIEW = View::Login
      def initialize(session, model)
        if session.request_method.eql?('POST')
          session.request_params
          xml_src = "#{session.request_params.keys.first} #{session.request_params.values.first}"
          unless xml_src.length == 0
            transaction = XmlConv::Util::Transaction.new
            transaction.domain      = session.server_name
            transaction.input       = xml_src
            transaction.reader      = 'SunStoreBdd'
            transaction.writer      = XmlConv::CONFIG.writer
            poll_config = YAML.load_file(XmlConv::CONFIG.polling_file)
            transaction.destination = XmlConv::Util::Destination.book(poll_config.destination)
            transaction.partner     = File.basename(session.request_path)
            transaction.origin      = session.request_origin
            transaction.postprocs.push(['Soap', 'update_partner'])
            transaction.postprocs.push(['Bbmb2', 'inject', XmlConv::CONFIG.bbmb_url, 'customer_id'])
            res = session.app.execute_with_response(transaction)
          end
        end
        super
      end
			def login
				if(@session.login)
					Transactions.new(@session, @session.persistence_layer.transactions)
				else
					self
				end
			end
			def transaction
				if((id = @session.user_input(:transaction_id)) \
					&& (transaction = @session.persistence_layer.transaction(id)))
					TransactionLogin.new(@session.persistence_layer, transaction)
				else
					self
				end
			end
		end
		class TransactionLogin < SBSM::State
			VIEW = View::Login
			def login
				if(@session.login)
					Transaction.new(@session.persistence_layer, @model)
				else
					self
				end
			end
		end
	end
end
