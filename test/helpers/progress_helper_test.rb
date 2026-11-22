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

  test "never raises on odd input" do
    [ nil, -5, "abc", "7", Float::NAN, Float::INFINITY ].each do |v|
      node = fragment(ui_progress(value: v)).at("[role=progressbar]")
      assert node["aria-valuenow"].to_f.between?(0, 100), v.inspect
    end
    assert fragment(ui_progress(value: 1, max: nil)).at("[role=progressbar]")
    assert fragment(ui_progress(value: 1, max: 0)).at("[role=progressbar]")
    assert fragment(ui_progress(value: 1, max: Float::NAN)).at("[role=progressbar]")
  end

  test "aria values are clamped, max may be a string, valuetext overridable" do
    node = fragment(ui_progress(value: 15, max: "10")).at("[role=progressbar]")
    assert_equal "10", node["aria-valuenow"]
    assert_equal "10", node["aria-valuemax"]
    assert_equal "0", node["aria-valuemin"]
    assert_equal "100%", node["aria-valuetext"]
    zero = fragment(ui_progress(value: 3, max: 0)).at("[role=progressbar]")
    assert_equal "0", zero["aria-valuenow"]
    assert_equal "100", zero["aria-valuemax"]
    assert_equal "3 of 10", fragment(ui_progress(value: 3, max: 10, "aria-valuetext": "3 of 10")).at("[role=progressbar]")["aria-valuetext"]
  end
end
