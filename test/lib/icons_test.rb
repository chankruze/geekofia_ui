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

  test "semantic maps cover exactly the semantic names and lucide files are bundled" do
    sem = GeekofiaUi::Icons::SEMANTIC.sort
    assert_equal sem, GeekofiaUi::Icons::LUCIDE_NAMES.keys.sort
    assert_equal sem, GeekofiaUi::Icons::FontAwesome::MAP.keys.sort
    assert_equal sem, GeekofiaUi::Icons::MaterialSymbols::MAP.keys.sort
    GeekofiaUi::Icons::LUCIDE_NAMES.each_value do |file|
      assert GeekofiaUi::Icons::Lucide::SVGS.key?(file), "bundled svg for #{file}"
    end
  end

  test "attributes are escaped, nested hashes expand, nil and false drop, true is bare" do
    icons = provider(:iconify)
    node = fragment(icons.render(:copy, size: 16, css_class: nil,
      attrs: { data: { foo: "bar" }, hidden: false, title: %(a "q" <b>), alt: nil, disabled: true })).at("iconify-icon")
    assert_equal "bar", node["data-foo"]
    assert_nil node["hidden"]
    assert_nil node["alt"]
    assert_equal %(a "q" <b>), node["title"]
    assert node.key?("disabled")
    html = icons.render(:copy, size: 16, css_class: nil, attrs: { title: "<script>" }).to_s
    assert_not_includes html, "<script>"
  end

  test "attribute keys cannot inject attributes" do
    html = provider(:lucide).render(:copy, size: 16, css_class: nil, attrs: { "x onmouseover=alert(1) y": "1" })
    node = fragment(html).at("svg")
    assert_nil node["onmouseover"]
    assert_not_includes node.attribute_nodes.map(&:name), "x onmouseover=alert(1) y"
  end

  test "svg attribute names keep their case and dashes" do
    html = provider(:lucide).render(:copy, size: 16, css_class: nil, attrs: {}).to_s
    assert_includes html, 'viewBox="0 0 24 24"'
    assert_includes html, 'stroke-width="2"'
  end

  test "strings are raw provider names and symbols are semantic on every provider" do
    assert_raises(ArgumentError) { provider(:lucide).render("alert_triangle", size: 16, css_class: nil, attrs: {}) }
    assert_includes fragment(provider(:font_awesome).render("alert_triangle", size: 16, css_class: nil, attrs: {})).at("i")["class"], "fa-alert_triangle"
    assert_equal "alert_triangle", fragment(provider(:iconify, icon_set: "mdi").render("alert_triangle", size: 16, css_class: nil, attrs: {})).at("iconify-icon")["icon"].split(":").last
    assert_equal "alert_triangle", fragment(provider(:material_symbols).render("alert_triangle", size: 16, css_class: nil, attrs: {})).at("span").text
    assert provider(:lucide).render(:alert_triangle, size: 16, css_class: nil, attrs: {}).present?
    assert_includes fragment(provider(:font_awesome).render(:alert_triangle, size: 16, css_class: nil, attrs: {})).at("i")["class"], "fa-triangle-exclamation"
    assert_equal "lucide:triangle-alert", fragment(provider(:iconify).render(:alert_triangle, size: 16, css_class: nil, attrs: {})).at("iconify-icon")["icon"]
    assert_equal "warning", fragment(provider(:material_symbols).render(:alert_triangle, size: 16, css_class: nil, attrs: {})).at("span").text
  end

  test "string alias keys are normalized and aliases work on lucide" do
    icons = provider(:iconify, icon_aliases: { "copy" => "ph:copy" })
    assert_equal "ph:copy", fragment(icons.render(:copy, size: 16, css_class: nil, attrs: {})).at("iconify-icon")["icon"]
    lucide = provider(:lucide, icon_aliases: { copy: "check" })
    assert_includes lucide.render(:copy, size: 16, css_class: nil, attrs: {}).to_s, "M20 6 9 17l-5-5"
  end

  test "head tags carry the nonce only when given" do
    {
      iconify: "script", font_awesome: "link", material_symbols: "link"
    }.each do |name, tag|
      icons = provider(name)
      assert_equal "abc123", fragment(icons.head_tags(nonce: "abc123")).at(tag)["nonce"], name.to_s
      assert_nil fragment(icons.head_tags).at(tag)["nonce"], name.to_s
    end
    kit = provider(:font_awesome, font_awesome_kit: "https://kit.fontawesome.com/abc.js")
    assert_equal "n1", fragment(kit.head_tags(nonce: "n1")).at("script")["nonce"]
    assert_nil fragment(kit.head_tags).at("script")["nonce"]
    assert_equal "", provider(:lucide).head_tags(nonce: "x").to_s
  end

  test "lucide misses in production log and render nothing" do
    icons = provider(:lucide)
    logged = []
    logger = Object.new
    logger.define_singleton_method(:warn) { |msg| logged << msg }
    original_env = Rails.env
    original_logger = Rails.logger
    begin
      Rails.env = ActiveSupport::EnvironmentInquirer.new("production")
      Rails.logger = logger
      assert_equal "", icons.render(:nope, size: 16, css_class: nil, attrs: {}).to_s
    ensure
      Rails.env = original_env
      Rails.logger = original_logger
    end
    assert_equal 1, logged.size
    assert_includes logged.first, "nope"
  end

  test "a class attribute extends rather than replaces required classes" do
    node = fragment(provider(:font_awesome).render(:copy, size: 16, css_class: "a", attrs: { class: "text-red-500" })).at("i")
    assert_equal %w[fa-solid fa-copy], node["class"].split.first(2)
    assert_includes node["class"], "text-red-500"
    assert_includes node["class"], "a"
    svg = fragment(provider(:lucide).render(:copy, size: 16, css_class: nil, attrs: { "class" => "x" })).at("svg")
    assert_includes svg["class"], "shrink-0"
    assert_includes svg["class"], "x"
  end

  test "a style attribute extends the generated size style" do
    [ :font_awesome, :material_symbols ].each do |name|
      tag = name == :font_awesome ? "i" : "span"
      [ :style, "style" ].each do |key|
        style = fragment(provider(name).render(:copy, size: 16, css_class: nil, attrs: { key => "color: red" })).at(tag)["style"]
        assert_includes style, "font-size: 16px", name.to_s
        assert_includes style, "color: red", name.to_s
      end
    end
    assert_includes fragment(provider(:lucide).render(:copy, size: 16, css_class: nil, attrs: { style: "color: red" })).at("svg")["style"], "color: red"
  end

  test "lucide svg loading skips files without extractable content" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "good.svg"), %(<svg a="1"><path d="M0 0"/></svg>))
      File.write(File.join(dir, "broken.svg"), "not an svg")
      File.write(File.join(dir, "empty.svg"), "<svg></svg>")
      svgs = GeekofiaUi::Icons::Lucide.load_svgs(dir)
      assert_equal [ "good" ], svgs.keys
    end
  end
end
