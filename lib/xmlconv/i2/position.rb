#!/usr/bin/env ruby
# I2::Position -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'xmlconv/i2/date'

module XmlConv
	module I2
		class Position
			attr_accessor :number, :article_ean, :qty, :customer_id, :price, :unit,
        :pharmacode, :free_text
			attr_reader :delivery_date
			def delivery_date=(date)
				date.code = :delivery
				@delivery_date = date
			end
			def to_s
				output = <<-EOS
500:#{@number}
        EOS
#        output << "501:#{@article_ean}\n"
        [@customer_id, @pharmacode].compact.each { |id|
          #output << sprintf("502:%s\n", id)
          output << sprintf("501:%s\n", id)
        }
        output << sprintf("520:%s\n", @qty)
        if(@unit)
          output << sprintf("521:%s\n", @unit)
        end
				if(@delivery_date.is_a?(I2::Date))
					output << @delivery_date.to_s
				end
        if(@price)
          output << sprintf("604:%s\n", @price)
        end
        if(@free_text)
          output << "605:RS\n"
          txt = @free_text[0,280] ## upper limit: 40 lines of 70 chars
          while(!txt.empty?)
            output << sprintf("606:%s\n", txt.slice!(0,70))
          end
        end
				output
			end
		end
	end
end
