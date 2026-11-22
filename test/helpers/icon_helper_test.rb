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
end
