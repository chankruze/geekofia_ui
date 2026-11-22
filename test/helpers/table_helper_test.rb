require "test_helper"

class GeekofiaUi::TableHelperTest < ActionView::TestCase
  test "head, body, rows and cells" do
    html = ui_table(id: "t") do |t|
      safe_join([
        t.head { |r| safe_join([ r.cell("Name"), r.cell("Size", class: "text-right") ]) },
        t.body { safe_join(%w[a b].map { |n| t.row(data: { name: n }) { |r| safe_join([ r.cell(n), r.cell { "1 GB" } ]) } }) }
      ])
    end
    doc = fragment(html)
    assert doc.at("div.overflow-x-auto > table#t")
    assert_equal %w[Name Size], doc.css("thead th").map { _1.text.strip }
    assert_includes doc.at("thead th:last-child")["class"], "text-right"
    assert_equal 2, doc.css("tbody tr").size
    assert_equal "b", doc.css("tbody tr").last["data-name"]
    assert_equal "1 GB", doc.at("tbody tr td:last-child").text.strip
  end

  test "block form output buffer keeps content exact" do
    html = render(inline: <<~ERB)
      <%= ui_card do |c| %>
        <%= c.content do %>
          <%= ui_table do |t| %>
            <%= t.head do |r| %><%= r.cell "A" %><%= r.cell "B" %><% end %>
            <%= t.body do %>
              <% 3.times do |i| %>
                <%= t.row(data: { i: i }) do |r| %>
                  <%= r.cell do %><strong>x</strong><% end %>
                  <%= r.cell "y" %>
                <% end %>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
        <%= c.footer do %>footer-text<% end %>
      <% end %>
    ERB
    doc = fragment(html)
    assert_equal 1, doc.css("table").size
    assert_equal 3, doc.css("tbody tr").size
    assert_equal 6, doc.css("tbody td").size
    assert_equal 2, doc.css("thead th").size
    assert_equal 3, doc.css("strong").size
    assert_equal 1, html.scan("footer-text").size
  end

  test "th defaults to scope col and header_cell is a row header" do
    html = ui_table do |t|
      safe_join([ t.head { |r| safe_join([ r.cell("A"), r.cell("B", scope: "colgroup") ]) },
                  t.body { t.row { |r| safe_join([ r.header_cell("Name"), r.cell("v") ]) } } ])
    end
    doc = fragment(html)
    assert_equal %w[col colgroup], doc.css("thead th").map { _1["scope"] }
    th = doc.at("tbody th")
    assert_equal "row", th["scope"]
    assert_equal "Name", th.text.strip
    assert_includes th["class"], "font-medium"
    assert_includes th["class"], "py-3"
    assert_includes doc.at("tbody td")["class"], "first:pl-6"
    assert_includes doc.at("thead th")["class"], "last:pr-6"
  end
end
