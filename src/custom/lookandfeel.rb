#!/usr/bin/env ruby
# Custom::Lookandfeel -- xmlconv2 -- 09.06.2004 -- hwyss@ywesee.com

require 'sbsm/lookandfeel'

module XmlConv
	module Custom
		class Lookandfeel < SBSM::Lookandfeel
			DICTIONARIES = {
				'de'	=>	{
					:home										=>	'Home',
					:login									=>	'Anmelden',
					:login_welcome					=>	'Willkommen bei XmlConv',
					:logout									=>	'Abmelden',
					:navigation_divider			=>	'|',
					:pass										=>	'Passwort',
					:status_open						=>	'offen',
					:status_pending_pickup	=>	'bereit zum abholen',
					:status_picked_up				=>	'abgeholt',
					:th_commit_time					=>	'Zeit',
					:th_input								=>	'Input',
					:th_uri									=>	'Empfänger',
					:th_filename						=>	'Filename',
					:th_transaction_id			=>	'ID',
					:th_origin							=>	'Absender',
					:th_output							=>	'Output',
					:th_status_comparable		=>	'Status',
				}
			}
			RESOURCES = {
				:css	=>	'xmlconv.css'
			}
		end
	end
end
