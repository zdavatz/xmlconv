#!/usr/bin/env ruby
# State::Transactions -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/transactions'

module XmlConv
	module State
		class Transactions < Global
			class PageFacade
				attr_accessor :model, :pages
				def initialize(int)
					@int = int
				end
				def next
					PageFacade.new(@int.next)
				end
				def pages
					@pages[[[@int - (PAGER_SIZE / 2), total - PAGER_SIZE].min, 
						0].max, PAGER_SIZE]
				end
				def previous
					PageFacade.new(@int-1)
				end
				def total
					@pages.size
				end
				def to_i
					@int
				end
				def to_s
					@int.next.to_s
				end
			end
			DIRECT_EVENT = :home
			PAGE_SIZE = 20
			PAGER_SIZE = 10
			REVERSE_MAP = {
				:commit_time => true,
			}
			VIEW = View::Transactions
			def init
				@transactions = @model
				@model = @transactions.reverse
				setup_pages
				@filter = Proc.new { 
					page
				}
				super
			end
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
			def page
				if(pge = @session.user_input(:page))
					@page = @pages[pge.to_i]
				else
					@page ||= @pages.first
				end
			end
			def page_size
				self::class::PAGE_SIZE
			end
			def self
				self
			end
			def setup_pages
				@pages = []
				@page = nil
				(@model.size / PAGE_SIZE.to_f).ceil.times { |pnum|
					page = PageFacade.new(pnum)
					page.model = @model[pnum * PAGE_SIZE, PAGE_SIZE]
					page.pages = @pages
					@pages.push(page)
				}
			end
			def size
				@model.size
			end
			def sort
				return self unless @model.is_a? Array
				get_sortby!
				@model = @transactions.dup
				@model.sort! { |a, b| compare_entries(a, b) }
				@model.reverse! if(@sort_reverse)
				setup_pages
				self
			end
			def transactions
				self
			end
		end
	end
end
