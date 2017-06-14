#!/usr/bin/env ruby
# State::Login -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/state'
require 'xmlconv/view/login'
require 'xmlconv/state/transactions'
require 'stringio'

module XmlConv
	module State
		class Login < SBSM::State
			VIEW = View::Login
      def initialize(session, model)
        if session.request_method.eql?('POST')
          xml_src = session.post_content
          SBSM.debug "XmlConv::State::Login POST params were #{session.request_params}"
          SBSM.debug " xml_src now #{xml_src}"
          unless xml_src.length == 0
            transaction = XmlConv::Util::Transaction.new
            transaction.domain      = session.server_name
            transaction.input       = xml_src
            transaction.reader      = 'SunStoreBdd'
            transaction.writer      = XmlConv::CONFIG.writer
            transaction.destination = XmlConv::Util::Destination.book(XmlConv::CONFIG.destination)
            transaction.partner     = File.basename(session.request_path)
            transaction.origin      = "http://#{session.remote_ip}"
            transaction.postprocs.push(['Soap', 'update_partner'])
            transaction.postprocs.push(['Bbmb2', 'inject', XmlConv::CONFIG.bbmb_url, 'customer_id'])
            @transaction = transaction
            res = session.app.execute_with_response(transaction)
          end
        end
        super
      end
      def to_html(context)
        if @session.request_method.eql?('POST')
          string = StringIO.new
          @transaction.response.write(string, 2)
          string.rewind
          string.read
        else
          super(context)
        end
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
