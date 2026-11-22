require "test_helper"

class GeekofiaUi::FeedbackHelperTest < ActionView::TestCase
  test "alert variants, auto icon and role" do
    node = fragment(ui_alert(title: "Degraded", variant: :destructive) { "md0 missing a disk" }).at("div")
    assert_equal "alert", node["role"]
    assert_equal "Degraded", node.at("p").text.strip
    assert_includes node.text, "md0 missing a disk"
    assert node.at("svg")
    assert_equal "status", fragment(ui_alert(variant: :info) { "x" }).at("div")["role"]
    assert_nil fragment(ui_alert(icon: nil) { "x" }).at("svg")
    assert_raises(ArgumentError) { ui_alert(variant: :loud) { "x" } }
  end

  test "flash maps notice and alert" do
    flash[:notice] = "Saved"
    flash[:alert] = "Broken"
    doc = fragment(ui_flash)
    assert_equal 2, doc.css("[role]").size
    assert_includes doc.text, "Saved"
    assert_includes doc.css("[role=alert]").text, "Broken"
  end
end
