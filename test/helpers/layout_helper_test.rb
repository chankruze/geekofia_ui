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

  test "partials render as html under a turbo_stream lookup format" do
    Mime::Type.register("text/vnd.turbo-stream.html", :turbo_stream) unless Mime[:turbo_stream]
    lookup_context.formats = [ :turbo_stream ]
    assert_nothing_raised do
      assert fragment(ui_empty_state(title: "None")).at("h3")
      assert fragment(ui_card { |c| c.header(title: "T") }).at("h2")
      assert fragment(ui_page_header(title: "P")).at("h1")
    end
  end

  test "block form output buffer keeps content exact" do
    html = render(inline: <<~ERB)
      <%= ui_card do |c| %>
        <%= c.header(title: "Outer") do %><span class="act">go</span><% end %>
        <%= c.content do %>
          <%= ui_card do |n| %>
            <%= n.content do %><strong>x</strong><% end %>
          <% end %>
        <% end %>
        <%= c.footer do %>footer-text<% end %>
      <% end %>
    ERB
    doc = fragment(html)
    assert_equal 2, doc.css("div.rounded-xl").size
    assert_equal 1, doc.css("strong").size
    assert_equal 1, doc.css("span.act").size
    assert_equal 1, html.scan("footer-text").size
    assert_equal 1, html.scan("Outer").size
  end

  test "titles and descriptions are escaped" do
    xss = "<script>alert(1)</script>"
    [ ui_card { |c| c.header(title: xss, description: xss) },
      ui_page_header(title: xss, description: xss),
      ui_empty_state(title: xss, description: xss) ].each do |html|
      assert_nil fragment(html).at("script")
      assert_includes html, "&lt;script&gt;"
    end
  end

  test "card header without block has no actions" do
    node = fragment(ui_card { |c| c.header(title: "T") })
    assert_nil node.at("div.shrink-0")
  end

  test "blank title and description render no elements" do
    assert_nil fragment(ui_card { |c| c.header(title: "", description: "") }).at("h2, p")
    node = fragment(ui_page_header(title: "", description: ""))
    assert_nil node.at("h1")
    assert_nil node.at("p")
    node = fragment(ui_empty_state(title: "", description: ""))
    assert_nil node.at("h3")
    assert_nil node.at("p")
  end

  test "empty state title_tag" do
    assert fragment(ui_empty_state(title: "T", title_tag: :h2)).at("h2")
  end

  test "card content and footer need a block" do
    %i[content footer].each do |name|
      error = assert_raises(ArgumentError) { ui_card { |c| c.public_send(name) } }
      assert_equal "ui_card #{name} needs a block", error.message
    end
  end

  test "page header and empty state accept class, attrs and title_tag" do
    node = fragment(ui_page_header(title: "T", title_tag: :h2, class: "mb-0", id: "ph", data: { x: "1" })).at("#ph")
    assert_includes node["class"], "mb-0"
    assert_includes node["class"], "flex"
    assert_equal "1", node["data-x"]
    assert node.at("h2")
    assert_nil node.at("h1")
    es = fragment(ui_empty_state(title: "N", class: "py-2", id: "es")).at("#es")
    assert_includes es["class"], "border-dashed"
    assert_includes es["class"], "py-2"
  end

  test "card header accepts class and attrs" do
    html = ui_card { |c| c.header(title: "H", class: "bg-muted", id: "ch") }
    node = fragment(html).at("#ch")
    assert_includes node["class"], "bg-muted"
    assert_includes node["class"], "p-6"
  end
end
