#!/usr/bin/env ruby
# I2::Header -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

module XmlConv
	module I2
		class Header
			attr_accessor :recipient_id, :filename, :prefix, :transaction_id
      attr_reader :suffix
			def initialize(recipient_id = 'EPIN_PL')
				@recipient_id = recipient_id
        @prefix = @recipient_id
        time = Time.now
				msec = sprintf('%03i', (time.to_f * 1000).to_i % 100)
        @transaction_id = time.strftime("%Y%m%d%H%M%S#{msec}.dat")
			end
      def suffix=(suffix)
        @suffix = "_" << suffix.to_s
      end
      def filename
        @filename || sprintf("%s%s_%s.dat", @prefix, @suffix, @transaction_id)
      end
			def to_s
				<<-EOS
001:#{@recipient_id}
002:ORDERX
003:220
010:#{filename}
				EOS
			end
		end
	end
end
