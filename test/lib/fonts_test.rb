require "test_helper"

class GeekofiaUi::FontsTest < ActiveSupport::TestCase
  def fonts(provider, **settings)
    settings.each { |k, v| GeekofiaUi.config.public_send(:"#{k}=", v) }
    GeekofiaUi.config.font_provider = provider
    GeekofiaUi.config.fonts
  end

  test "system has no tags and native stacks" do
    f = fonts(:system, font_sans: "Inter")
    assert_equal "", f.head_tags
    assert_equal "", f.head_tags(nonce: "abc")
    assert_equal GeekofiaUi::Fonts::SANS_STACK, f.stacks[:sans]
    assert_equal GeekofiaUi::Fonts::MONO_STACK, f.stacks[:mono]
  end

  test "google builds one stylesheet with weights and preconnects" do
    f = fonts(:google, font_sans: "Inter", font_mono: "JetBrains Mono", font_weights: [ 400, 600 ])
    tags = f.head_tags
    assert_includes tags, "fonts.gstatic.com"
    assert_includes tags, "family=Inter:wght@400;600&amp;family=JetBrains+Mono:wght@400;600&amp;display=swap"
    assert_equal %("Inter", #{GeekofiaUi::Fonts::SANS_STACK}), f.stacks[:sans]
  end

  test "bunny uses its own slug format" do
    tags = fonts(:bunny, font_sans: "Inter", font_mono: "JetBrains Mono").head_tags
    assert_includes tags, "https://fonts.bunny.net/css?family=inter:400,500,600,700|jetbrains-mono:400,500,600,700&amp;display=swap"
  end

  test "google and bunny add nonce to every tag only when given" do
    %i[google bunny].each do |provider|
      f = fonts(provider, font_sans: "Inter")
      assert_no_match(/nonce/, f.head_tags)
      tags = f.head_tags(nonce: "n0nce")
      assert_equal({ google: 3, bunny: 2 }.fetch(provider), tags.scan(%(nonce="n0nce")).size)
      assert_equal tags.scan("<link").size, tags.scan('nonce="n0nce"').size
    end
  end

  test "google and bunny emit nothing without families" do
    assert_equal "", fonts(:google, font_sans: nil, font_mono: nil).head_tags(nonce: "x")
    assert_equal "", fonts(:bunny, font_sans: nil, font_mono: nil).head_tags(nonce: "x")
  end

  test "families outside the allowlist raise" do
    [ "Foo\\", "a}b", "a;b", 'a"b', "a<b", "a\nb", "a&b", "a+b" ].each do |bad|
      %i[google bunny self_hosted].each do |provider|
        f = fonts(provider, font_sans: bad, font_mono: nil)
        error = assert_raises(ArgumentError, "#{provider} #{bad.inspect}") { f.stacks; f.head_tags }
        assert_includes error.message, bad.inspect
      end
    end
  end

  test "families are stripped" do
    f = fonts(:google, font_sans: " Inter ", font_mono: nil)
    assert_equal %("Inter", #{GeekofiaUi::Fonts::SANS_STACK}), f.stacks[:sans]
    assert_includes f.head_tags, "family=Inter:wght@"
  end

  test "family names are url encoded" do
    g = fonts(:google, font_sans: "Font's Name", font_mono: "A.B", font_weights: [ 400 ]).head_tags
    assert_includes g, "family=Font%27s+Name:wght@400&amp;family=A.B:wght@400"
    assert_includes fonts(:google, font_sans: "Foo Bar", font_mono: nil).head_tags, "family=Foo+Bar:wght@"
    b = fonts(:bunny, font_sans: "Foo Bar", font_mono: "Font's Name", font_weights: [ 400 ]).head_tags
    assert_includes b, "foo-bar:400|font-s-name:400"
  end

  test "weights are normalised" do
    assert_includes fonts(:google, font_sans: "Inter", font_mono: nil, font_weights: [ 700, 400, 400 ]).head_tags, "wght@400;700"
    assert_includes fonts(:bunny, font_sans: "Inter", font_mono: nil, font_weights: [ 700, 400, 400 ]).head_tags, "inter:400,700"
    g = fonts(:google, font_sans: "Inter", font_mono: nil, font_weights: []).head_tags
    assert_includes g, "css2?family=Inter&amp;display=swap"
    assert_no_match(/wght/, g)
    assert_includes fonts(:bunny, font_sans: "Inter", font_mono: nil, font_weights: []).head_tags, "css?family=inter&amp;display=swap"
    assert_includes fonts(:google, font_sans: "Inter", font_mono: nil, font_weights: "400").head_tags, "wght@400"
  end

  test "families dedupe case-insensitively" do
    tags = fonts(:google, font_sans: "Inter", font_mono: "inter", font_weights: [ 400 ]).head_tags
    assert_equal 1, tags.scan("family=").size
  end

  test "gstatic preconnect has crossorigin anonymous" do
    tags = fonts(:google, font_sans: "Inter", font_mono: nil).head_tags
    assert_includes tags, 'crossorigin="anonymous"'
  end

  test "self hosted only sets stacks" do
    f = fonts(:self_hosted, font_sans: "Brand Sans")
    assert_equal "", f.head_tags
    assert_equal "", f.head_tags(nonce: "abc")
    assert_equal %("Brand Sans", #{GeekofiaUi::Fonts::SANS_STACK}), f.stacks[:sans]
  end

  test "custom provider and unknown symbol" do
    custom = Object.new
    def custom.head_tags = "<x>".html_safe
    def custom.stacks = { sans: "a", mono: "b" }
    assert_equal "<x>", fonts(custom).head_tags
    GeekofiaUi.config.font_provider = :nope
    assert_raises(ArgumentError) { GeekofiaUi.config.fonts }
  end
end
