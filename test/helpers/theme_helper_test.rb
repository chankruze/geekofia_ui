require "test_helper"

class GeekofiaUi::ThemeHelperTest < ActionView::TestCase
  teardown { GeekofiaUi.reset_config! }

  # Real views get this from the controller; ActionView::TestCase has none.
  def content_security_policy_nonce = "test-nonce"

  test "toggle wires the theme controller with three icons" do
    node = fragment(ui_theme_toggle).at("button")
    assert_equal "ui-theme", node["data-controller"]
    assert_equal "ui-theme#cycle", node["data-action"]
    assert_equal "system", node["data-theme"]
    assert_equal 3, node.css("svg").size
  end

  test "head tags include theme script, font stacks and provider tags" do
    GeekofiaUi.configure do |c|
      c.font_provider = :bunny
      c.font_sans = "Inter"
      c.icon_provider = :iconify
    end
    html = ui_head_tags
    assert_includes html, "geekofia-ui-theme"
    assert_includes html, %(--ui-font-sans:"Inter")
    assert_includes html, "fonts.bunny.net"
    assert_includes html, "iconify-icon"
  end

  test "theme script accepts an explicit theme" do
    html = ui_head_tags
    assert_includes html, "function a(t){"
    assert_includes html, "t=t||"
    assert_includes html, "applyTheme:a"
  end

  test "head tags work with providers whose head_tags takes no nonce" do
    legacy = Object.new
    def legacy.stacks = { sans: "x", mono: "y" }
    def legacy.head_tags = "<!-- legacy -->".html_safe
    modern = Object.new
    def modern.stacks = { sans: "x", mono: "y" }
    def modern.head_tags(nonce: nil) = "<!-- modern -->".html_safe
    config = GeekofiaUi.config
    swap = lambda do |fonts, icons|
      config.define_singleton_method(:fonts) { fonts }
      config.define_singleton_method(:icons) { icons }
    end
    swap.call(legacy, modern)
    html = ui_head_tags
    assert_includes html, "legacy"
    assert_includes html, "modern"
    swap.call(modern, legacy)
    assert_includes ui_head_tags, "legacy"
  ensure
    config.singleton_class.send(:remove_method, :fonts)
    config.singleton_class.send(:remove_method, :icons)
  end
end
