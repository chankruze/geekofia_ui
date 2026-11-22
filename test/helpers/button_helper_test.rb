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

  test "http verb is normalised" do
    form = fragment(ui_button("Remove", href: "/x", method: "DELETE")).at("form")
    assert form.at("input[name=_method][value=delete]")
    assert fragment(ui_button("Go", href: "/x", method: "GET")).at("a")
  end

  test "GET params go into the url, not attributes" do
    node = fragment(ui_button("Go", href: "/x", params: { kind: "health" })).at("a")
    assert_equal "/x?kind=health", node["href"]
    assert_nil node["params"]
    assert_equal "/x?a=1&kind=health", fragment(ui_button("Go", href: "/x?a=1", params: { kind: "health" })).at("a")["href"]
  end

  test "button_to form defaults to inline-flex and passes params as hidden inputs" do
    form = fragment(ui_button("Run", href: "/x", method: :post, params: { kind: "health" })).at("form")
    assert_includes form["class"], "inline-flex"
    assert form.at("input[type=hidden][name=kind][value=health]")
  end

  test "classes, data and aria land on the button, not the form" do
    form = fragment(ui_button("Run", href: "/x", method: :post, class: "mine", data: { a: "1" }, aria: { label: "Run it" })).at("form")
    button = form.at("button")
    assert_includes button["class"], "mine"
    assert_equal "1", button["data-a"]
    assert_equal "Run it", button["aria-label"]
    assert_not_includes form["class"].to_s, "mine"
    assert_nil form["data-a"]
  end

  test "labels are escaped on every path" do
    [ ui_button("<b>x</b>"), ui_button("<b>x</b>", href: "/x"), ui_button("<b>x</b>", href: "/x", method: :post) ].each do |html|
      frag = fragment(html)
      assert_nil frag.at("b")
      assert_includes frag.text, "<b>x</b>"
    end
  end

  test "caller classes beat variant colours and size-" do
    node = fragment(ui_button("x", variant: :ghost, class: "text-destructive hover:text-destructive")).at("button")
    assert_includes node["class"], "text-destructive"
    assert_not_includes node["class"], "hover:text-accent-foreground"
    icon = fragment(ui_button("x", size: :icon, class: "size-8")).at("button")["class"].split
    assert_includes icon, "size-8"
    assert_not_includes icon, "size-9"
  end

  test "link with icon and plain button type" do
    assert fragment(ui_button("Go", href: "/x", icon: :copy)).at("a svg")
    assert_equal "submit", fragment(ui_button("Go", type: "submit")).at("button")["type"]
  end

  test "caller form class wins and no form_class attribute leaks" do
    form = fragment(ui_button("Run", href: "/x", method: :post, form: { class: "mine" })).at("form")
    assert_equal "mine", form["class"]
    assert_nil form.at("button")["form_class"]
    assert_nil form.at("button")["form-class"]
  end
end
