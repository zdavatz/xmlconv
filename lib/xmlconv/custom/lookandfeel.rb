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
					:page_back								=>	"&lt;&lt;",
					:page_fwd									=>	"&gt;&gt;",
					:page_number0							=>	"Seite&nbsp;",
					:page_number1							=>	"&nbsp;von&nbsp;",
					:page_number2							=>	"",
					:pass											=>	'Passwort',
					:status_bbmb_ok						=>	'Bestellung via BBMB erfolgreich',
					:status_empty							=>	'Leer',
					:status_error							=>	'Fehler',
					:status_http_ok						=>	'&Uuml;bertragung erfolgreich',
					:status_http_not_found		=>	'URI nicht gefunden',
					:status_http_unauthorized	=>	'Keine Berechtigung',
					:status_open							=>	'Offen',
					:status_pending_pickup		=>	'Bereit zum Abholen',
					:status_picked_up					=>	'Abgeholt',
					:th_commit_time						=>	'Zeit',
					:th_error									=>	'Fehler',
					:th_input									=>	'Input',
					:th_uri_comparable				=>	'Empfänger',
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
