#!/usr/bin/env ruby
# Custom::Lookandfeel -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/lookandfeel'

module XmlConv
	module Custom
		class Lookandfeel < SBSM::Lookandfeel
			DICTIONARIES = {
				'de'	=>	{
					:copyright0								=>	'&copy;ywesee.com&nbsp;',
					:copyright1								=>	'',
					:home											=>	'Home',
					:login										=>	'Anmelden',
					:login_welcome						=>	'Willkommen bei XmlConv',
					:logout										=>	'Abmelden',
					:navigation_divider				=>	'|',
					:page_last								=>	"&nbsp;&lt;&lt;&nbsp;",
					:page_next								=>	"&nbsp;&gt;&gt;&nbsp;",
					:pager0										=>	"&nbsp;",
					:pager1										=>	"&nbsp;bis&nbsp;",
					:pager2										=>	"&nbsp;von&nbsp;",
					:pager3										=>	"",
					:pager_entries0						=>	"",
					:pager_entries1						=>	"&nbsp;Eintr&auml;ge&nbsp;gefunden",
					:pass											=>	'Passwort',
					:status_http_ok						=>	'&Uuml;bertragung erfolgreich',
					:status_http_not_found		=>	'URI nicht gefunden',
					:status_http_unauthorized	=>	'Keine Berechtigung',
					:status_open							=>	'Offen',
					:status_pending_pickup		=>	'Bereit zum Abholen',
					:status_picked_up					=>	'Abgeholt',
					:th_commit_time						=>	'Zeit',
					:th_input									=>	'Input',
					:th_uri										=>	'Empfänger',
					:th_filename							=>	'Filename',
					:th_transaction_id				=>	'ID',
					:th_origin								=>	'Absender',
					:th_output								=>	'Output',
					:th_status_comparable			=>	'Status',
				}
			}
			RESOURCES = {
				:css	=>	'xmlconv.css'
			}
		end
	end
end
