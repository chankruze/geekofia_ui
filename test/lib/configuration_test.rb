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

  test "writers clear the memoized providers" do
    c = GeekofiaUi.config
    c.instance_variable_set(:@icons, :sentinel)
    c.icon_set = "other"
    assert_nil c.instance_variable_get(:@icons)
    c.instance_variable_set(:@fonts, :sentinel)
    c.font_weights = [ 400 ]
    assert_nil c.instance_variable_get(:@fonts)
  end

  test "default collections are frozen" do
    c = GeekofiaUi::Configuration.new
    assert_predicate c.icon_aliases, :frozen?
    assert_predicate c.font_weights, :frozen?
  end
end
