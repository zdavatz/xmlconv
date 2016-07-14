$: << File.dirname(__FILE__)
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'minitest/autorun'
require 'flexmock/minitest'
require 'xmlconv/util/application'
require 'xmlconv/util/session'
require 'xmlconv/custom/lookandfeel'

module XmlConv
  class TestApplication < Util::Application
    def unknown_user; end
  end

  module Custom
    class TestLookandfeel < ::Minitest::Test
      def setup
        @app     = TestApplication.new
        @session = Util::Session.new('test', @app)
      end

      def test_base_url_does_not_include_flavor
        lookandfeel = Lookandfeel.new(@session)
        assert_equal('sbsm', lookandfeel.flavor)
        assert_equal('sbsm', @session.flavor)
        refute_match(@session.flavor, lookandfeel.base_url)
      end
    end
  end
end
