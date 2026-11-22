require "test_helper"

class GeekofiaUi::CopyHelperTest < ActionView::TestCase
  test "copy button wires the clipboard controller" do
    node = fragment(ui_copy_button("ssh-rsa AAAA")).at("button")
    assert_equal "ui-clipboard", node["data-controller"]
    assert_equal "ui-clipboard#copy", node["data-action"]
    assert_equal "ssh-rsa AAAA", node["data-ui-clipboard-text-value"]
    assert_includes node.text, "Copy"
    assert_includes node.text, "Copied"
  end

  test "copy button has a live status region" do
    status = fragment(ui_copy_button("x")).at("button [data-ui-clipboard-target=status]")
    assert status
    assert_equal "status", status["role"]
    assert_equal "polite", status["aria-live"]
    assert_includes status["class"], "sr-only"
  end

  test "copy from a source selector, and argument check" do
    node = fragment(ui_copy_button(source: "#run_log", label: "Copy log")).at("button")
    assert_equal "#run_log", node["data-ui-clipboard-source-value"]
    assert_raises(ArgumentError) { ui_copy_button }
  end

  test "code block with copy and wrap" do
    doc = fragment(ui_code_block("echo hi", wrap: true))
    assert_equal "echo hi", doc.at("pre code").text
    assert_includes doc.at("pre")["class"], "whitespace-pre-wrap"
    assert_equal "echo hi", doc.at("button")["data-ui-clipboard-text-value"]
    assert_nil fragment(ui_code_block("x", copy: false)).at("button")
  end
end
