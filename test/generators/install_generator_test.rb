require "test_helper"
require "generators/geekofia_ui/install/install_generator"

class GeekofiaUi::InstallGeneratorTest < Rails::Generators::TestCase
  tests GeekofiaUi::Generators::InstallGenerator
  destination File.expand_path("../../tmp/generator", __dir__)

  setup do
    prepare_destination
    FileUtils.mkdir_p(File.join(destination_root, "app/assets/tailwind"))
    FileUtils.mkdir_p(File.join(destination_root, "app/javascript/controllers"))
    FileUtils.mkdir_p(File.join(destination_root, "app/views/layouts"))
    File.write(File.join(destination_root, "app/assets/tailwind/application.css"), %(@import "tailwindcss";\n))
    File.write(File.join(destination_root, "app/javascript/controllers/index.js"),
               %(import { application } from "controllers/application"\nimport { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"\neagerLoadControllersFrom("controllers", application)\n))
    File.write(File.join(destination_root, "app/views/layouts/application.html.erb"),
               %(<html>\n  <head>\n    <%= stylesheet_link_tag :app %>\n  </head>\n</html>\n))
  end

  test "installs once and is idempotent" do
    2.times { run_generator }
    assert_file "app/assets/tailwind/application.css" do |css|
      assert_equal 1, css.scan(%(@import "../builds/tailwind/geekofia_ui";)).size
      assert css.index("tailwindcss") < css.index("geekofia_ui")
    end
    assert_file "app/javascript/controllers/index.js" do |js|
      assert_equal 1, js.scan(%(eagerLoadControllersFrom("geekofia_ui/controllers", application))).size
    end
    assert_file "app/views/layouts/application.html.erb" do |layout|
      assert_equal 1, layout.scan("ui_head_tags").size
      assert layout.index("ui_head_tags") < layout.index("stylesheet_link_tag")
    end
    assert_file "config/initializers/geekofia_ui.rb", /GeekofiaUi.configure/
  end
end
