# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xmlconv/version'

Gem::Specification.new do |spec|
  spec.name        = "xmlconv"
  spec.version     = XmlConv::VERSION
  spec.author      = "Masaomi Hatakeyama, Zeno R.R. Davatz, Niklaus Giger"
  spec.email       = "mhatakeyama@ywesee.com, zdavatz@ywesee.com, ngiger@ywesee.com"
  spec.description = "xmlconverter, convert XML to flat files. A Ruby gem"
  spec.summary     = "xmlconverter, convert XML to flat files"
  spec.homepage    = "https://github.com/zdavatz/xmlconv"
  spec.license       = "GPL-v2"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "odba",    '>= 1.1.2'
  spec.add_dependency "ydbd-pg", '>= 0.5.1'
  spec.add_dependency "ydbi",    '>= 0.5.1'
  spec.add_dependency "json"
  # Must not include mail and use specific old version of some gems to
  # allow mod_ruby compiled against Ruby 1.8.6 as on fastpower
  if /^1\./.match(RUBY_VERSION)
    spec.add_dependency "sbsm", '1.2.6'
    spec.add_dependency "htmlgrid", '1.0.7'
    spec.add_dependency "ydim",    '1.0.0'
    spec.add_dependency "hpricot", '0.8.2'
  else
    spec.add_dependency "sbsm"
    spec.add_dependency "htmlgrid"
    spec.add_dependency "ydim"
    spec.add_dependency "syck"
    spec.add_dependency "mail" # avoid it to make it run
  end
  spec.add_dependency "rclconf"
  spec.add_dependency "needle"
  spec.add_dependency "ypdf-writer"
  spec.add_runtime_dependency 'deprecated', '= 2.0.1'

  spec.add_runtime_dependency "yus"

  spec.add_development_dependency "bundler"
  unless /^1\.8/.match(RUBY_VERSION)
    spec.add_development_dependency "simplecov"
    spec.add_development_dependency "rake"
    spec.add_development_dependency "flexmock"
    spec.add_development_dependency "minitest"
    spec.add_development_dependency "minitest-should_syntax"
    spec.add_development_dependency "rspec"
  end
end

