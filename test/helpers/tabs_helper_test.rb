require "test_helper"

class GeekofiaUi::TabsHelperTest < ActionView::TestCase
  def tabs_html(path: "/servers/1", **opts)
    request.path = path
    ui_tabs(label: "Server sections", **opts) do |t|
      safe_join([
        t.tab("Overview", href: "/servers/1"),
        t.tab("Packages", href: "/servers/1/packages", match: :prefix, badge: 3, badge_variant: :destructive),
        t.tab("Storage", href: "/servers/1/storage", dot: :warning, dot_label: "health warning")
      ])
    end
  end

  def link(html, text) = fragment(html).css("a").find { |a| a.text.include?(text) }

  test "nav wraps scrollable list of links" do
    nav = fragment(tabs_html).at("nav")
    assert_equal "Server sections", nav["aria-label"]
    assert nav.at("div.overflow-x-auto")
    assert_equal %w[/servers/1 /servers/1/packages /servers/1/storage], nav.css("a").map { |a| a["href"] }
    assert_includes nav.css("a").first.text, "Overview"
  end

  test "exact match marks only the current tab" do
    html = tabs_html
    overview = link(html, "Overview")
    assert_equal "page", overview["aria-current"]
    assert_includes overview["class"], "border-foreground"
    other = link(html, "Packages")
    assert_not other.key?("aria-current")
    assert_not_includes other["class"], "border-foreground"
  end

  test "prefix match" do
    html = tabs_html(path: "/servers/1/packages/all")
    assert_equal "page", link(html, "Packages")["aria-current"]
    assert_not link(html, "Overview").key?("aria-current")
  end

  test "active override" do
    request.path = "/servers/1"
    html = ui_tabs(label: "x") do |t|
      safe_join([ t.tab("A", href: "/servers/1", active: false), t.tab("B", href: "/other", active: true) ])
    end
    assert_not link(html, "A").key?("aria-current")
    assert_equal "page", link(html, "B")["aria-current"]
  end

  test "badge" do
    badge = link(tabs_html, "Packages").at("span.rounded-md")
    assert_equal "3", badge.text
    assert_includes badge["class"], "text-destructive"
    request.path = "/servers/1"
    html = ui_tabs(label: "x") { |t| safe_join([ t.tab("A", href: "/a", badge: 0), t.tab("B", href: "/b", badge: nil) ]) }
    assert_nil fragment(html).at("span.rounded-md")
  end

  test "dot" do
    storage = link(tabs_html, "Storage")
    dot = storage.at("span[aria-hidden=true]")
    assert_includes dot["class"], "bg-warning"
    assert_equal "health warning", storage.at("span.sr-only").text
    html = ui_tabs(label: "x") { |t| t.tab("A", href: "/a", dot: :success) }
    assert_equal "attention", fragment(html).at("span.sr-only").text
    assert_raises(ArgumentError) { ui_tabs(label: "x") { |t| t.tab("A", href: "/a", dot: :purple) } }
  end

  test "caller class merges onto nav" do
    nav = fragment(tabs_html(class: "mb-4")).at("nav")
    assert_includes nav["class"], "mb-4"
    assert_includes nav["class"], "border-b"
  end
end
