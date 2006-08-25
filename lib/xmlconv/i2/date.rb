#!/usr/bin/env ruby
# I2::Date -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'date'

module XmlConv
	module I2
		class Date < ::Date
			attr_accessor :code, :level
			class << self
				def from_date(date, level=nil, code=nil)
					instance = self.new(date.year, date.month, date.day)
          instance.code = code
          instance.level = level
          instance
				end
			end
			def to_s
				fmtd = strftime("%Y%m%d")
        datecd = case @code
                 when :delivery
                   '2'
                 else
                   '4'
                 end
        case @level
        when :order
					<<-EOS
300:#{datecd}
301:#{fmtd}
					EOS
        else
					<<-EOS
540:#{datecd}
541:#{fmtd}
					EOS
				end
			end
		end
	end
end
