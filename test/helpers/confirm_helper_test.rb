require "test_helper"

class GeekofiaUi::ConfirmHelperTest < ActionView::TestCase
  test "dialog markup" do
    dialog = fragment(ui_confirm_dialog).at("dialog[data-controller=ui-confirm]")
    assert_equal "alertdialog", dialog["role"]
    assert_equal "ui-confirm-title", dialog["aria-labelledby"]
    assert_equal "ui-confirm-message", dialog["aria-describedby"]
    assert_includes dialog["data-ui-confirm-destructive-class-value"], "bg-destructive"
    assert_includes dialog["data-ui-confirm-default-class-value"], "bg-primary"
    assert dialog.at("form[method=dialog]")
    cancel = dialog.at("button[value=cancel][data-ui-confirm-target=cancel]")
    assert cancel.key?("autofocus")
    assert dialog.at("button[value=confirm][data-ui-confirm-target=confirm]")
    assert dialog.at("#ui-confirm-title[data-ui-confirm-target=title]")
    assert dialog.at("#ui-confirm-message[data-ui-confirm-target=message]")
  end
end
