#!/usr/bin/env ruby
#  -- rpdf2txt -- 01.06.2004 -- hwyss@ywesee.com

#!/usr/bin/env ruby
#  -- rpdf2txt -- 01.06.2004 -- hwyss@ywesee.com

#!/usr/bin/env ruby
# DeliveryItem -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		class DeliveryItem
			attr_accessor :line_no, :qty, :delivery_date
			attr_reader :part_ids, :et_nummer
			def initialize
				@part_ids = {}
			end
			def add_part_id(domain, value)
				@part_ids.store(domain, value)
				if(domain && !domain.empty?)
					var = domain.gsub(/-/, '_').downcase
					instance_variable_set("@#{var}", value)
				end
			end
		end
	end
end
