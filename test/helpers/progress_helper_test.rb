require "test_helper"

class GeekofiaUi::ProgressHelperTest < ActionView::TestCase
  test "width, tone and aria" do
    node = fragment(ui_progress(value: 42, tone: :warning)).at("[role=progressbar]")
    assert_equal "42", node["aria-valuenow"]
    bar = node.at("div")
    assert_includes bar["style"], "width: 42.0%"
    assert_includes bar["class"], "bg-warning"
    assert_includes fragment(ui_progress(value: 150)).at("div div")["style"], "100.0%"
    assert_raises(ArgumentError) { ui_progress(value: 1, tone: :blue) }
  end
end
