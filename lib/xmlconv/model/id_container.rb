#!/usr/bin/env ruby
# IdContainer -- xmlconv2 -- 01.06.2004 -- hwyss@ywesee.com

module XmlConv
	module Model
		module IdContainer
			def acc_id
				self.id_table['acc']
			end
			def add_id(domain, value)
				self.id_table.store(domain.to_s.downcase, value)
				self.ids.store(domain, value)
			end
			def ids
				@ids ||= {}
			end
      def id_table
        @id_table ||= {}
      end
		end
	end
end
