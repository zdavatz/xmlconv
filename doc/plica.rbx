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

	#=begin
	if(request.request_method != 'POST')
		request.status = 405 # Method not allowed
		exit
	end
	allowed = XmlConv::Access::ALLOWED_HOSTS[File.basename(request.filename)]
	unless(allowed && allowed.include?(connection.remote_ip))
		request.status = 403 # Forbidden
		exit
	end
	#=end

	content_length = request.headers_in['Content-Length'].to_i
	if(content_length <= 0)
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
	puts err.class
	puts err.message
	puts err.backtrace
	request.status = 500
end

