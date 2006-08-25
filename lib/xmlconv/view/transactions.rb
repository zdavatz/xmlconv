#!/usr/bin/env ruby
# View::Transactions -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/value'
require 'xmlconv/view/template'
require 'xmlconv/view/pager'

module XmlConv
	module View
		class TransactionsList < HtmlGrid::List
			BACKGROUND_SUFFIX = ' bg'
			COMPONENTS = {
				[0,0]	=>	:transaction_id,
				[1,0]	=>	:origin,
				[2,0]	=>	:commit_time,
				[3,0]	=>	:uri_comparable,
				[4,0]	=>	:status_comparable,
			}
			CSS_CLASS = 'composite'
			CSS_HEAD_MAP = {
				[0,0]	=>	'right',
			}
			CSS_MAP = {
				[0,0]		=>	'list right',
				[1,0,4]	=>	'list',
			}
			DEFAULT_CLASS = HtmlGrid::Value
			LEGACY_INTERFACE = false
			SORT_DEFAULT = nil #:commit_time
			SORT_REVERSE = false
			def commit_time(model)
				time_format(model.commit_time || model.start_time)
			end
			def origin(model)
				uri_fmt(model.origin)
			end
			def uri_comparable(model)
				uri_fmt(model.uri)
			end
			def uri_fmt(uri)
				uri = uri.to_s
				if((i1 = uri.index(/([^\/])\/[^\/]/, 1)) \
						&& (i2 = uri.rindex(/(\/[^\/]+){3}/)) \
						&& (i2 > i1))
					uri[0..(i1.next)] << '...' << uri[i2..-1]
				else 
					uri
				end
			end
			def status_comparable(model)
				model.update_status
				status = model.status
				@lookandfeel.lookup("status_#{status}") or status.to_s
			end
			def time_format(a_time)
				if(a_time.respond_to?(:strftime))
					a_time.strftime("%d.%m.%Y %H:%M:%S") 
				end
			end
			def transaction_id(model)
				link = HtmlGrid::Link.new(:transaction_id, model, @session, self)
				args = {
					'transaction_id'	=>	model.transaction_id,
				}
				link.href = @lookandfeel.event_url(:transaction, args)
				link.value = model.transaction_id
				link
			end
		end
		class TransactionsComposite < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	:pager,
				[0,1]	=>	:transactions,
			}
			CSS_CLASS = 'composite'
			LEGACY_INTERFACE = false
			def pager(model)
				Pager.new(model.pages, @session, self)
			end
			def transactions(page)
				TransactionsList.new(page.model, @session, self)
			end
		end
		class Transactions < Template
			CONTENT = TransactionsComposite
			#CONTENT = TransactionsList
		end
	end
end
