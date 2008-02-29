#!/usr/bin/env ruby
# Model::Document -- xmlconv -- 03.12.2007 -- hwyss@ywesee.com

module XmlConv
  module Model
    class Document < String
			attr_accessor :recipient_id, :filename, :prefix, :transaction_id
      def initialize(*args)
        super
				@recipient_id = recipient_id
        @prefix = @recipient_id
        time = Time.now
				msec = sprintf('%03i', (time.to_f * 1000).to_i % 100)
        @transaction_id = time.strftime("%Y%m%d%H%M%S#{msec}")
      end
      def filename
        @filename || sprintf(XmlConv::CONFIG.default_filename, 
                             @prefix, @suffix, @transaction_id)
      end
      def to_s
        "" << self
      end
    end
	end
end
