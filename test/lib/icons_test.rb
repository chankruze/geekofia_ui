require "test_helper"

class GeekofiaUi::IconsTest < ActiveSupport::TestCase
  def provider(name, **settings)
    settings.each { |k, v| GeekofiaUi.config.public_send(:"#{k}=", v) }
    GeekofiaUi.config.icon_provider = name
    GeekofiaUi.config.icons
  end

  test "every built-in provider maps every semantic name" do
    %i[lucide iconify font_awesome material_symbols].each do |name|
      icons = provider(name)
      GeekofiaUi::Icons::SEMANTIC.each do |semantic|
        html = icons.render(semantic, size: 16, css_class: nil, attrs: { "aria-hidden": "true" })
        assert html.present?, "#{name} renders #{semantic}"
      end
    end
  end

  test "lucide renders inline svg with size, class and attributes" do
    node = fragment(provider(:lucide).render(:copy, size: 20, css_class: "text-red-500", attrs: { "aria-hidden": "true" })).at("svg")
    assert_equal "20", node["width"]
    assert_equal "currentColor", node["stroke"]
    assert_includes node["class"], "text-red-500"
    assert_equal "true", node["aria-hidden"]
    assert node.at("path, rect, circle, line, polyline"), "has shapes"
  end

  test "lucide refuses unknown or path-like names in test env" do
    icons = provider(:lucide)
    assert_raises(ArgumentError) { icons.render(:nope, size: 16, css_class: nil, attrs: {}) }
    assert_raises(ArgumentError) { icons.render("../../etc/passwd", size: 16, css_class: nil, attrs: {}) }
  end

  test "iconify qualifies names and adds its script" do
    icons = provider(:iconify, icon_set: "mdi")
    assert_equal "lucide:copy", fragment(icons.render(:copy, size: 16, css_class: nil, attrs: {})).at("iconify-icon")["icon"]
    assert_equal "mdi:server", fragment(icons.render("server", size: 16, css_class: nil, attrs: {})).at("iconify-icon")["icon"]
    assert_equal "tabler:x", fragment(icons.render("tabler:x", size: 16, css_class: nil, attrs: {})).at("iconify-icon")["icon"]
    assert_includes icons.head_tags, "iconify-icon"
  end

  test "aliases override semantic names" do
    icons = provider(:iconify, icon_aliases: { copy: "ph:copy-bold" })
    assert_equal "ph:copy-bold", fragment(icons.render(:copy, size: 16, css_class: nil, attrs: {})).at("iconify-icon")["icon"]
  end

  test "font awesome uses style classes and stylesheet or kit" do
    icons = provider(:font_awesome)
    assert_equal "fa-solid fa-copy", fragment(icons.render(:copy, size: 16, css_class: nil, attrs: {})).at("i")["class"].split.first(2).join(" ")
    assert_includes icons.head_tags, "font-awesome"
    kit = provider(:font_awesome, font_awesome_kit: "https://kit.fontawesome.com/abc.js")
    assert_includes kit.head_tags, "kit.fontawesome.com/abc.js"
  end

  test "material symbols renders ligature text" do
    icons = provider(:material_symbols)
    assert_equal "content_copy", fragment(icons.render(:copy, size: 16, css_class: nil, attrs: {})).at("span").text
    assert_includes icons.head_tags, "Material+Symbols+Outlined"
  end

  test "custom provider objects are used as-is and unknown symbols raise" do
    custom = Object.new
    def custom.render(name, **) = "<b>#{name}</b>".html_safe
    def custom.head_tags = "".html_safe
    GeekofiaUi.config.icon_provider = custom
    assert_equal "<b>copy</b>", GeekofiaUi.config.icons.render(:copy, size: 16, css_class: nil, attrs: {})
    GeekofiaUi.config.icon_provider = :bogus
    assert_raises(ArgumentError) { GeekofiaUi.config.icons }
  end
end
