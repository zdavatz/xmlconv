#!/usr/bin/env ruby
# I2::Header -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

module XmlConv
	module I2
		class Header
			attr_accessor :recipient_id, :filename
			def initialize
				@recipient_id = 'EPIN_PLICA'
				@filename = Time.now.strftime("#{@recipient_id}_%Y%m%d%H%M%S.dat")
			end
			def to_s
				<<-EOS
001:#{@recipient_id}
002:ORDERX
003:220
010:#{@filename}
				EOS
			end
		end
	end
end
