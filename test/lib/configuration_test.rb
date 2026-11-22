require "test_helper"

class GeekofiaUi::ConfigurationTest < ActiveSupport::TestCase
  test "defaults" do
    c = GeekofiaUi.config
    assert_equal :lucide, c.icon_provider
    assert_equal "lucide", c.icon_set
    assert_equal({}, c.icon_aliases)
    assert_equal "solid", c.font_awesome_style
    assert_equal :system, c.font_provider
    assert_equal [ 400, 500, 600, 700 ], c.font_weights
  end

  test "configure yields the config and reset restores defaults" do
    GeekofiaUi.configure { |c| c.icon_provider = :iconify }
    assert_equal :iconify, GeekofiaUi.config.icon_provider
    GeekofiaUi.reset_config!
    assert_equal :lucide, GeekofiaUi.config.icon_provider
  end
end
