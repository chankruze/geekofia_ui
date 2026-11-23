require "test_helper"

class GeekofiaUi::DropdownHelperTest < ActionView::TestCase
  def menu_html(**opts)
    ui_dropdown_menu(**opts) do |m|
      safe_join([
        m.item("Edit", href: "/e", icon: :pencil),
        m.separator,
        m.item("Delete", href: "/d", method: :delete, variant: :destructive,
               confirm: { message: "Sure?", title: "Delete x?", button: "Delete", variant: :destructive })
      ])
    end
  end

  test "trigger, hidden menu, items, separator and confirm attributes" do
    root = fragment(menu_html(label: "More actions")).at("[data-controller=ui-dropdown]")
    trigger = root.at("button[data-ui-dropdown-target=trigger]")
    assert_equal "menu", trigger["aria-haspopup"]
    assert_equal "false", trigger["aria-expanded"]
    assert_equal "More actions", trigger["aria-label"]
    assert trigger.at("svg")
    menu = root.at("[role=menu][data-ui-dropdown-target=menu]")
    assert menu.key?("hidden")
    assert_includes menu["class"], "right-0"
    edit = menu.at("a[role=menuitem]")
    assert_equal "/e", edit["href"]
    assert_equal "-1", edit["tabindex"]
    assert menu.at("[role=separator]")
    form = menu.at("form")
    assert_equal "/d", form["action"]
    assert form.at("input[name=_method][value=delete]")
    assert_equal "Sure?", form["data-turbo-confirm"]
    assert_equal "Delete x?", form["data-confirm-title"]
    assert_equal "Delete", form["data-confirm-button"]
    assert_equal "destructive", form["data-confirm-variant"]
    assert_includes form.at("button[role=menuitem]")["class"], "text-destructive"
  end

  test "align start, escaping and invalid options" do
    assert_includes fragment(menu_html(align: :start)).at("[role=menu]")["class"], "left-0"
    html = ui_dropdown_menu(label: "<b>x</b>") { |m| m.item("<i>y</i>", href: "/y") }
    assert_not_includes html, "<b>x</b>"
    assert_not_includes html, "<i>y</i>"
    assert_raises(ArgumentError) { menu_html(align: :middle) }
    assert_raises(ArgumentError) { ui_dropdown_menu { |m| m.item("x", href: "/x", variant: :loud) } }
  end

  test "root data merges controllers and keeps other keys, class merges, turbo cache action" do
    root = fragment(ui_dropdown_menu(class: "mt-2", data: { controller: "other", foo: "1", action: "click->x#y" }) { |m| m.item("a", href: "/a") }).at("div")
    assert_equal "ui-dropdown other", root["data-controller"]
    assert_equal "1", root["data-foo"]
    assert_includes root["class"], "mt-2"
    assert_includes root["class"], "relative"
    assert_includes root["data-action"], "turbo:before-cache@document->ui-dropdown#close"
    assert_includes root["data-action"], "click->x#y"
    default = fragment(menu_html).at("[data-controller=ui-dropdown]")
    assert_includes default["data-action"], "turbo:before-cache@document->ui-dropdown#close"
  end

  test "item data merges and uses select action" do
    html = ui_dropdown_menu do |m|
      safe_join([ m.item("a", href: "/a", data: { turbo_frame: "_top" }),
                  m.item("b", href: "/b", data: { action: "click->x#y" }) ])
    end
    a, b = fragment(html).css("a[role=menuitem]")
    assert_equal "ui-dropdown#select", a["data-action"]
    assert_equal "_top", a["data-turbo-frame"]
    assert_includes b["data-action"], "ui-dropdown#select"
    assert_includes b["data-action"], "click->x#y"
  end

  test "trigger and menu are linked by ids" do
    root = fragment(menu_html).at("[data-controller=ui-dropdown]")
    trigger = root.at("button[data-ui-dropdown-target=trigger]")
    menu = root.at("[role=menu]")
    assert trigger["id"].present?
    assert menu["id"].present?
    assert_equal menu["id"], trigger["aria-controls"]
    assert_equal trigger["id"], menu["aria-labelledby"]
    assert_nil menu["aria-label"]
  end

  test "get items append params, explicit get is a link, non-get params become hidden inputs" do
    html = ui_dropdown_menu do |m|
      safe_join([ m.item("a", href: "/a", params: { x: 1 }), m.item("b", href: "/b?q=1", method: :get, params: { x: 1 }),
                  m.item("c", href: "/c", method: :post, params: { y: "2" }) ])
    end
    links = fragment(html).css("a[role=menuitem]")
    assert_equal "/a?x=1", links[0]["href"]
    assert_equal "/b?q=1&x=1", links[1]["href"]
    assert fragment(html).at("form input[name=y][value='2']")
  end

  test "string confirm, missing message and invalid variant" do
    html = ui_dropdown_menu { |m| m.item("d", href: "/d", method: :delete, confirm: "Sure?") }
    assert_equal "Sure?", fragment(html).at("form")["data-turbo-confirm"]
    assert_raises(ArgumentError) { ui_dropdown_menu { |m| m.item("d", href: "/d", method: :delete, confirm: { title: "t" }) } }
    assert_raises(ArgumentError) do
      ui_dropdown_menu { |m| m.item("d", href: "/d", method: :delete, confirm: { message: "m", variant: :loud }) }
    end
  end

  test "trigger icon override" do
    default = fragment(menu_html).at("button svg").to_html
    other = fragment(menu_html(icon: :plus)).at("button svg").to_html
    assert_not_equal default, other
  end
end
