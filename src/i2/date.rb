#!/usr/bin/env ruby
# I2::Date -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'date'

module XmlConv
	module I2
		class Date < ::Date
			attr_accessor :code
			class << self
				def from_date(date)
					self.new(date.year, date.month, date.day)
				end
			end
			def to_s
				# NOTE
				# DTSTTCPW here and now is to allow only two possibilities for 
				# I2::Date:
				# Order-Date on the Order-Level (300:4\n301:strftime) and 
				# Delivery-Date on the Position-Level (540:2\n540:strftime)
				# This code is likely to change.
				fmtd = strftime("%Y%m%d")
				if(@code == :delivery)
					<<-EOS
540:2
541:#{fmtd}
					EOS
				else
					<<-EOS
300:4
301:#{fmtd}
					EOS
				end
			end
		end
	end
end
