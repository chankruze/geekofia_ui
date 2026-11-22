require "test_helper"

class GeekofiaUi::LayoutHelperTest < ActionView::TestCase
  test "card with header, content and footer" do
    html = ui_card(class: "mt-4", id: "disks") do |c|
      safe_join([ c.header(title: "Disks", description: "2 found") { ui_button("Run") },
                  c.content { "body" }, c.footer { "foot" } ])
    end
    card = fragment(html).at("#disks")
    assert_includes card["class"], "rounded-xl"
    assert_includes card["class"], "mt-4"
    assert_equal "Disks", card.at("h2").text.strip
    assert_equal "2 found", card.at("p").text.strip
    assert card.at("button")
    assert_includes card.text, "body"
    assert_includes card.text, "foot"
  end

  test "page header with badge and actions" do
    node = fragment(ui_page_header(title: "office1", description: "LAN", badge: ui_badge("ok")) { ui_button("Edit") })
    assert_equal "office1", node.at("h1").text.strip
    assert node.at("h1 + span, h1 ~ span")
    assert node.at("button")
  end

  test "empty state" do
    node = fragment(ui_empty_state(title: "No servers", description: "Add one", icon: :server) { ui_button("Add") })
    assert_equal "No servers", node.at("h3").text.strip
    assert node.at("svg")
    assert node.at("button")
  end
end
