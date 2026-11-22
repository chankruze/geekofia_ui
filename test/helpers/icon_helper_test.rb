require "test_helper"

class GeekofiaUi::IconHelperTest < ActionView::TestCase
  test "decorative by default, labelled when asked" do
    assert_equal "true", fragment(ui_icon(:copy)).at("svg")["aria-hidden"]
    node = fragment(ui_icon(:copy, aria_label: "Copy", size: 24, class: "text-primary")).at("svg")
    assert_equal "img", node["role"]
    assert_equal "Copy", node["aria-label"]
    assert_equal "24", node["width"]
    assert_includes node["class"], "text-primary"
  end

  test "aria label given through attrs counts as labelled" do
    [ ui_icon(:x, aria: { label: "Close" }), ui_icon(:x, "aria-label": "Close") ].each do |html|
      node = fragment(html).at("svg")
      assert_equal "Close", node["aria-label"]
      assert_equal "img", node["role"]
      assert_nil node["aria-hidden"]
      assert_equal 1, html.scan("aria-label").size
    end
  end

  test "size is coerced to an integer and invalid sizes raise" do
    assert_equal "20", fragment(ui_icon(:copy, size: "20")).at("svg")["width"]
    assert_raises(ArgumentError) { ui_icon(:copy, size: "big") }
    assert_raises(TypeError) { ui_icon(:copy, size: nil) }
  end
end
