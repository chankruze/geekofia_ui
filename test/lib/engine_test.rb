require "test_helper"
require "open3"
require "tmpdir"

class GeekofiaUi::EngineTest < ActiveSupport::TestCase
  class Host
    include GeekofiaUi::Helpers::Support
  end

  test "helpers are mixed into views" do
    assert ActionView::Base.private_method_defined?(:ui_classes)
  end

  test "ui_option! accepts strings and symbols and returns a symbol" do
    assert_equal :sm, Host.new.send(:ui_option!, :size, "sm", %i[sm md])
    assert_equal :md, Host.new.send(:ui_option!, :size, :md, %i[sm md])
  end

  test "ui_option! raises listing the allowed values" do
    error = assert_raises(ArgumentError) { Host.new.send(:ui_option!, :size, "xl", %i[sm md]) }
    assert_includes error.message, "size"
    assert_includes error.message, ":sm, :md"
  end

  test "ui_classes delegates to ClassMerge" do
    assert_equal GeekofiaUi::ClassMerge.call("p-2", "p-4"), Host.new.send(:ui_classes, "p-2", "p-4")
  end

  test "engine css exists with the tokens and sources" do
    css = GeekofiaUi::Engine.root.join("app/assets/tailwind/geekofia_ui/engine.css").read
    assert_includes css, "@custom-variant dark"
    assert_includes css, "--color-primary: var(--primary)"
    assert_includes css, "--color-popover: var(--popover)"
    assert_includes css, '@source "../../../views"'
  end

  test "importmap pins the controllers" do
    # pin_all_from registers a directory, not entries in `packages`, so check
    # the expanded import map as the host would emit it.
    pins = JSON.parse(Rails.application.importmap.to_json(resolver: ActionController::Base.helpers))["imports"].keys
    assert_includes pins, "geekofia_ui/controllers/ui_clipboard_controller"
    assert_includes pins, "geekofia_ui/controllers/ui_theme_controller"
  end

  test "engine css compiles with tailwind and scans engine sources" do
    begin
      require "tailwindcss-rails"
      exe = Tailwindcss::Ruby.executable
    rescue LoadError, NameError => e
      skip "tailwindcss-ruby not loadable: #{e.message}"
    end

    root = GeekofiaUi::Engine.root
    probe = root.join("app/views/geekofia_ui/zz_probe_tmp.html.erb")
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "application.css"),
        %(@import "tailwindcss";\n@import "#{root.join("app/assets/tailwind/geekofia_ui/engine.css")}";\n@source "./page.html";\n))
      File.write(File.join(dir, "page.html"), %(<div class="bg-success/15 font-mono bg-popover bg-background"></div>))
      FileUtils.mkdir_p(probe.dirname)
      File.write(probe, %(<div class="underline-offset-[7px]"></div>))
      out, status = Open3.capture2e(exe, "-i", "application.css", "-o", "out.css", chdir: dir)
      assert status.success?, out
      css = File.read(File.join(dir, "out.css"))
      %w[.bg-success\\/15 .font-mono .bg-popover .bg-background .underline-offset-\\[7px\\]].each { |sel| assert_includes css, sel }
    ensure
      FileUtils.rm_f(probe)
    end
  end
end
