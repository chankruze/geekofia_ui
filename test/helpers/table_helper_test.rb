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
end
