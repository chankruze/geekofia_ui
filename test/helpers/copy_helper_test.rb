require "test_helper"

class GeekofiaUi::CopyHelperTest < ActionView::TestCase
  test "copy button wires the clipboard controller" do
    doc = fragment(ui_copy_button("ssh-rsa AAAA"))
    wrapper = doc.at("span[data-controller]")
    node = doc.at("button")
    assert_equal "ui-clipboard", wrapper["data-controller"]
    assert_equal "ssh-rsa AAAA", wrapper["data-ui-clipboard-text-value"]
    assert_nil node["data-controller"]
    assert_equal "ui-clipboard#copy", node["data-action"]
    assert_includes node.text, "Copy"
    assert_includes node.text, "Copied"
  end

  test "copy button has a live status region" do
    doc = fragment(ui_copy_button("x"))
    assert_nil doc.at("button [data-ui-clipboard-target=status]")
    status = doc.at("span[data-controller] > [data-ui-clipboard-target=status]")
    assert status
    assert_equal "status", status["role"]
    assert_equal "polite", status["aria-live"]
    assert_includes status["class"], "sr-only"
  end

  test "copy from a source selector, and argument check" do
    doc = fragment(ui_copy_button(source: "#run_log", label: "Copy log", data: { foo: "bar" }, id: "cb"))
    assert_equal "#run_log", doc.at("span[data-controller]")["data-ui-clipboard-source-value"]
    assert_equal "bar", doc.at("span[data-controller]")["data-foo"]
    assert_equal "cb", doc.at("button")["id"]
    assert_raises(ArgumentError) { ui_copy_button }
  end

  test "code block with copy and wrap" do
    doc = fragment(ui_code_block("echo hi", wrap: true))
    assert_equal "echo hi", doc.at("pre code").text
    assert_includes doc.at("pre")["class"], "whitespace-pre-wrap"
    assert_equal "echo hi", doc.at("[data-ui-clipboard-text-value]")["data-ui-clipboard-text-value"]
    assert_nil fragment(ui_code_block("x", copy: false)).at("button")
  end

  test "code block padding, copy label and language sanitising" do
    assert_includes fragment(ui_code_block("x")).at("pre")["class"], "pr-12"
    assert_not_includes fragment(ui_code_block("x", copy: false)).at("pre")["class"], "pr-12"
    assert_equal "Copy cmd", fragment(ui_code_block("x", copy_label: "Copy cmd")).at("button")["aria-label"]
    assert_equal "language-rubyx", fragment(ui_code_block("x", language: 'ruby" x')).at("code")["class"]
    assert_includes fragment(ui_code_block("x")).at("div div")["class"], "backdrop-blur-sm"
  end
end
