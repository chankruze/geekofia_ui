require "test_helper"

class GeekofiaUi::EngineTest < ActiveSupport::TestCase
  test "helpers are mixed into views" do
    assert ActionView::Base.method_defined?(:ui_classes, true) || ActionView::Base.private_method_defined?(:ui_classes)
  end

  test "engine css exists with the tokens and sources" do
    css = GeekofiaUi::Engine.root.join("app/assets/tailwind/geekofia_ui/engine.css").read
    assert_includes css, "@custom-variant dark"
    assert_includes css, "--color-primary: var(--primary)"
    assert_includes css, '@source "../../../views"'
  end

  test "importmap pins the controllers" do
    # pin_all_from registers a directory, not entries in `packages`, so check
    # the expanded import map as the host would emit it.
    pins = JSON.parse(Rails.application.importmap.to_json(resolver: ActionController::Base.helpers))["imports"].keys
    assert_includes pins, "geekofia_ui/controllers/ui_clipboard_controller"
    assert_includes pins, "geekofia_ui/controllers/ui_theme_controller"
  end
end
