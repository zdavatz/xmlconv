#!/usr/bin/env ruby
# View::Pager -- xmlconv2 -- 01.07.2004 -- ywesee@ywesee.com

require 'htmlgrid/link'
require 'htmlgrid/list'

module XmlConv
	module View
		class Pager < HtmlGrid::List
			BACKGROUND_SUFFIX = ''
			COMPONENTS = {
				[0,0]	=>	:number_link,
			}
			CSS_CLASS = 'pager'
			CSS_HEAD_MAP = {
				#[0,0]	=>	'pager-head',
			}
			CSS_MAP = {
				#[0,0]	=>	'pager',
			}
			LEGACY_INTERFACE = false
			OFFSET_STEP = [1,0]
			SORT_DEFAULT = :to_i
			SORT_HEADER = false
			def init
				@page = @container.model
				super
			end
			def compose_header(offset)
				@grid.add(page_number(@model), *offset)
				@grid.add_style('head', *offset)
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
				if(@page != @model.first)
					link = page_link(@page.previous)
					link.value = @lookandfeel.lookup(:page_back)
					@grid.add(link, *offset)
				end
				#@grid.add_attribute('class', 'pager', *offset)
				resolve_offset(offset, self::class::OFFSET_STEP)
			end
			def compose_footer(offset)
				if(@page != @model.last)
					link = page_link(@page.next)
					link.value = @lookandfeel.lookup(:page_fwd)
					@grid.add(link, *offset)
				else
					@grid.add(nil, *offset)
				end
			end
			private
			def number_link(model)
				page_link(model)
			end
			def page_link(page)
				if(page != @page)
					link = HtmlGrid::Link.new(:self, page, @session, self)
					link.value = page.to_s
					#link.set_attribute("class", "pager")
					values = {
						:page	=>	page.to_i.to_s,
						:state_id	=>	@session.state.id,
					}
					link.href = @lookandfeel.event_url(:self, values)
					link
				else
					page.to_s
				end
			end
			def page_number(model)
				@lookandfeel.lookup(:page_number, @page, model.size)
			end
		end
	end
end
