require "test_helper"

class GeekofiaUi::ButtonHelperTest < ActionView::TestCase
  test "plain button with default variant and size" do
    node = fragment(ui_button("Save")).at("button")
    assert_equal "button", node["type"]
    assert_equal "Save", node.text.strip
    assert_includes node["class"], "bg-primary"
    assert_includes node["class"], "h-9"
  end

  test "variants, sizes, icon and class merge" do
    node = fragment(ui_button("Delete", variant: :destructive, size: :sm, icon: :trash, class: "px-8")).at("button")
    assert_includes node["class"], "bg-destructive"
    assert_includes node["class"], "px-8"
    assert_not_includes node["class"], "px-3"
    assert node.at("svg")
  end

  test "GET href renders a link, other methods a button_to form" do
    assert_equal "/x", fragment(ui_button("Go", href: "/x")).at("a")["href"]
    form = fragment(ui_button("Remove", href: "/x", method: :delete, form: { data: { turbo_confirm: "Sure?" } })).at("form")
    assert_equal "/x", form["action"]
    assert_equal "Sure?", form["data-turbo-confirm"]
    assert form.at("input[name=_method][value=delete]")
    assert form.at("button[type=submit]")
  end

  test "block content and invalid options" do
    assert_equal "Hi", fragment(ui_button { "Hi" }).at("button").text.strip
    assert_raises(ArgumentError) { ui_button("x", variant: :huge) }
    assert_raises(ArgumentError) { ui_button("x", size: :xxl) }
  end
end
