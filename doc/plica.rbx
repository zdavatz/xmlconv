#!/usr/bin/env ruby
# plica.rbx -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

require 'drb/drb'
require 'rexml/document'
require 'util/application'
require 'util/destination'
require 'util/transaction'
require 'etc/config'

begin
	request = Apache.request
	connection = request.connection

	request.server.log_notice("Received Request #{request.request_method}")
	#=begin
	if(request.request_method != 'POST')
		request.status = 405 # Method not allowed
		exit
	end
	allowed = XmlConv::Access::ALLOWED_HOSTS[File.basename(request.filename)]
	request.server.log_notice("from #{connection.remote_ip}")
=begin
	unless(allowed && allowed.include?(connection.remote_ip))
		request.status = 403 # Forbidden
		request.server.log_error("remote_ip not in ALLOWED_HOSTS")
		exit
	end
=end

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
	destination.path = File.expand_path('../ftp/janico',
		File.dirname(__FILE__))

	transaction = XmlConv::Util::Transaction.new
	transaction.input = xml_src
	transaction.reader = 'XmlBdd'
	transaction.writer = 'BddI2'
	transaction.destination = destination
	transaction.origin = "http://#{connection.remote_ip}:#{connection.remote_port}"

	xmlconv.execute(transaction)

rescue StandardError => err
	request.server.log_error(err.class)
	request.server.log_error(err.message)
	request.server.log_error(err.backtrace.join("\n"))
	request.status = 500
ensure
	request.send_http_header
end

