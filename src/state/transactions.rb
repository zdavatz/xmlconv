#!/usr/bin/env ruby
# State::Transactions -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/transactions'

module XmlConv
	module State
		class Transactions < Global
			DIRECT_EVENT = :home
			REVERSE_MAP = {
				:commit_time => true,
			}
			VIEW = View::Transactions
			def compare_entries(a, b)
				@sortby.each { |sortby|
					aval, bval = nil
					begin
						aval = a.send(sortby)
						bval = b.send(sortby)
					rescue
						next
					end
					res = if(aval.nil? && bval.nil?)
						0
					elsif(aval.nil?)
						1
					elsif(bval.nil?)
						-1
					else
						aval <=> bval
					end
					return res unless(res == 0)
				}
				0
			end
			def get_sortby!
				@sortby ||= []
				sortvalue = @session.user_input(:sortvalue)
				if(sortvalue.is_a? String)
					sortvalue = sortvalue.intern
				end
				if(@sortby.first == sortvalue)
					@sort_reverse = !@sort_reverse
				else
					@sort_reverse = self.class::REVERSE_MAP[sortvalue]
				end
				@sortby.delete_if { |sortby|
					sortby == sortvalue
				}
				@sortby.unshift(sortvalue)
			end
			def sort
				return self unless @model.is_a? Array
				get_sortby!
				@transactions ||= @model
				@model = @transactions.dup
				@model.sort! { |a, b| compare_entries(a, b) }
				@model.reverse! if(@sort_reverse)
				self
			end
		end
	end
end
