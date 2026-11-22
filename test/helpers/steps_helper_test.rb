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

  test "done steps are announced and the list keeps its role" do
    doc = fragment(ui_steps { |s| safe_join([ s.step(title: "A", done: true), s.step(title: "B") ]) })
    assert_equal "list", doc.at("ol")["role"]
    assert_includes doc.css("li").first.at("span.sr-only").text, "Completed"
    assert_nil doc.css("li").last.at("span.sr-only")
  end

  test "step accepts class and attrs on its li" do
    doc = fragment(ui_steps { |s| s.step(title: "A", class: "opacity-50", id: "s1", data: { k: "v" }) })
    li = doc.at("li#s1")
    assert_includes li["class"], "opacity-50"
    assert_includes li["class"], "flex"
    assert_equal "v", li["data-k"]
  end
end
