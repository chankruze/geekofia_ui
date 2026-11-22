require "test_helper"

class GeekofiaUi::StepsHelperTest < ActionView::TestCase
  test "numbers steps and marks done ones" do
    html = ui_steps do |s|
      safe_join([ s.step(title: "Copy key", done: true) { "a" }, s.step(title: "Test") ])
    end
    doc = fragment(html)
    items = doc.css("ol > li")
    assert_equal 2, items.size
    assert items.first.at("svg"), "done step shows a check"
    assert_equal "2", items.last.at("span").text.strip
    assert_equal "Test", items.last.at("p").text.strip
  end
end
