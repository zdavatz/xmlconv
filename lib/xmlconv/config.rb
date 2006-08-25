#!/usr/bin/env ruby
# Config -- xmlconv2 -- 21.08.2006 -- hwyss@ywesee.com

require 'rclconf/rclconf'

module XmlConv
  conf_dir = '/etc/xmlconv'
  data_dir = '/var/lib/xmlconv'
  code_dir = '/usr/lib/xmlconv'
  if(home = ENV['HOME'])
    conf_dir = File.join(home, '.xmlconv')
    data_dir = File.join(conf_dir, 'data')
    code_dir = File.join(conf_dir, 'plugin')
  elsif(document_root = ENV['DOCUMENT_ROOT'])
    conf_dir = File.join(document_root, 'etc')
    data_dir = File.join(document_root, 'data')
    code_dir = File.join(document_root, 'lib')
  end
  default_config_files = [
    File.join(conf_dir, 'xmlconv.yml'),
    '/etc/xmlconv/xmlconv.yml',
  ]
  defaults = {
    'config'			      => default_config_files,
    'db_name'           => 'xmlconv',
    'db_user'           => 'xmlconv',
    'db_auth'           => '',
    'grammar_dir'       => data_dir,
    'log_file'          => STDERR,
    'log_level'         => 'INFO',
    'pass_hash'         => "6646c9e7892ef147dbed611a00ea48e6",
    'polling_file'      => conf_dir,
    'program_name'      => 'XmlConv2',
    'project_root'      => data_dir,
    'plugin_dir'        => File.expand_path('conversion', code_dir),
    'server_url'        => 'druby://localhost:10010',
    'ydim_id'           => nil,
    'vat_rate'          => 7.6,
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)

  CONFIG = config
end
