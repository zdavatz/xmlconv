#!/usr/bin/env ruby
# geh.rbx -- xmlconv2 -- 24.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'drb/drb'
require 'util/destination'
require 'util/transaction'
require 'etc/config'

begin
	request = Apache.request
	connection = request.connection

	request.server.log_notice("Received Request #{request.request_method}")
	if(request.request_method != 'POST')
		request.status = 405 # Method not allowed
		exit
	end
	request.server.log_notice("from #{connection.remote_ip}")

	content_length = request.headers_in['Content-Length'].to_i
	request.server.log_notice("content-length: #{content_length}")
	if(content_length <= 0)
		request.status = 500 # Server Error
		request.server.log_error("zero length input")
		exit
	end

	xml_src = $stdin.read(content_length)

	DRb.start_service
	xmlconv = DRbObject.new(nil, XmlConv::SERVER_URI)
	destination = XmlConv::Util::DestinationDir.new
	destination.path = File.expand_path('../ftp/janico/geh/out',
		File.dirname(__FILE__))

	transaction = XmlConv::Util::Transaction.new
	transaction.input = xml_src
	transaction.reader = 'GehBdd'
	transaction.writer = 'BddI2'
	transaction.destination = destination
	transaction.origin = "http://#{connection.remote_ip}:#{connection.remote_port}"

	xmlconv.dispatch(transaction)

rescue StandardError => err
	request.server.log_error(err.class.to_s)
	request.server.log_error(err.message)
	request.server.log_error(err.backtrace.join("\n"))
	request.status = 500
ensure
	request.send_http_header
end
