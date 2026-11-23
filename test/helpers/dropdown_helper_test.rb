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
end
