require "test_helper"

class GeekofiaUi::BadgeHelperTest < ActionView::TestCase
  test "variants, dot and attributes" do
    node = fragment(ui_badge("ok", variant: :success, dot: true, data: { status: "ok" })).at("span")
    assert_includes node["class"], "text-success"
    assert_equal "ok", node["data-status"]
    assert node.at("span[aria-hidden]"), "dot"
    assert_equal "ok", node.text.strip
    assert_raises(ArgumentError) { ui_badge("x", variant: :neon) }
  end
end
