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
               %(<html>\n  <head>\n    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>\n  </head>\n  <body>\n    <%= yield %>\n  </body>\n</html>\n))
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
    assert_file "app/views/layouts/application.html.erb" do |layout|
      assert_equal 1, layout.scan("ui_confirm_dialog").size
      assert layout.index("ui_confirm_dialog") < layout.index("</body>")
    end
  end

  test "layout without a closing body tag is skipped with a hint for the confirm dialog" do
    write "app/views/layouts/application.html.erb", "<html><head><%= stylesheet_link_tag :app %></head></html>\n"
    out = run_generator
    assert_no_match(/ui_confirm_dialog/, read("app/views/layouts/application.html.erb"))
    assert_match(/add <%= ui_confirm_dialog %> before <\/body> of app\/views\/layouts\/application.html.erb/, out)
  end

  test "confirm dialog goes before the last closing body tag" do
    write "app/views/layouts/application.html.erb", "<!-- </body> -->\n<body>\n</body>\n"
    run_generator
    layout = read("app/views/layouts/application.html.erb")
    assert_equal "<!-- </body> -->\n<body>\n    <%= ui_confirm_dialog %>\n</body>\n", layout
  end

  test "appends the controllers line on its own line when index.js has no trailing newline" do
    write "app/javascript/controllers/index.js", %(eagerLoadControllersFrom("controllers", application))
    run_generator
    assert_file "app/javascript/controllers/index.js" do |js|
      assert_equal([ %(eagerLoadControllersFrom("controllers", application)),
                    %(eagerLoadControllersFrom("geekofia_ui/controllers", application)) ], js.lines.map(&:chomp))
    end
  end

  test "css import works without a trailing newline" do
    write "app/assets/tailwind/application.css", %(@import "tailwindcss";)
    run_generator
    assert_equal %(@import "tailwindcss";\n@import "../builds/tailwind/geekofia_ui";\n), read("app/assets/tailwind/application.css")
  end

  test "css import works with single quotes" do
    write "app/assets/tailwind/application.css", %(@import 'tailwindcss';\n.a {}\n)
    run_generator
    assert_equal %(@import 'tailwindcss';\n@import "../builds/tailwind/geekofia_ui";\n.a {}\n), read("app/assets/tailwind/application.css")
  end

  test "css import works with source() modifiers" do
    write "app/assets/tailwind/application.css", %(@import "tailwindcss" source(none);\n)
    run_generator
    assert_equal %(@import "tailwindcss" source(none);\n@import "../builds/tailwind/geekofia_ui";\n), read("app/assets/tailwind/application.css")
  end

  test "css without a tailwind import is skipped with a hint" do
    write "app/assets/tailwind/application.css", %(.a {}\n)
    out = run_generator
    assert_equal %(.a {}\n), read("app/assets/tailwind/application.css")
    assert_match(/add @import "..\/builds\/tailwind\/geekofia_ui";? after @import "tailwindcss"/, out)
  end

  test "layout without stylesheet_link_tag is skipped with a hint" do
    write "app/views/layouts/application.html.erb", "<html><head></head></html>\n"
    out = run_generator
    assert_equal "<html><head></head></html>\n", read("app/views/layouts/application.html.erb")
    assert_match(/add <%= ui_head_tags %> inside <head> of app\/views\/layouts\/application.html.erb/, out)
  end

  test "missing files are skipped" do
    FileUtils.rm_rf(File.join(destination_root, "app"))
    out = run_generator
    assert_match(/skip/, out)
    assert_file "config/initializers/geekofia_ui.rb"
  end

  test "re-running reports identical and keeps a user-edited initializer" do
    run_generator
    path = File.join(destination_root, "config/initializers/geekofia_ui.rb")
    File.write(path, "# mine\n")
    out = run_generator
    assert_equal "# mine\n", File.read(path)
    assert_match(/identical/, out)
  end

  test "layout with two stylesheet tags gets head tags once before the first" do
    write "app/views/layouts/application.html.erb",
          %(<head>\n  <%= stylesheet_link_tag :app %>\n  <%= stylesheet_link_tag :other %>\n</head>\n)
    run_generator
    layout = read("app/views/layouts/application.html.erb")
    assert_equal 1, layout.scan("ui_head_tags").size
    assert layout.index("ui_head_tags") < layout.index("stylesheet_link_tag :app")
  end

  test "css with two tailwind imports gets the import once" do
    write "app/assets/tailwind/application.css", %(@import "tailwindcss";\n@import "tailwindcss";\n)
    run_generator
    assert_equal 1, read("app/assets/tailwind/application.css").scan("geekofia_ui").size
  end

  test "css import matches an indented tailwind import" do
    write "app/assets/tailwind/application.css", %(  @import "tailwindcss";\n)
    run_generator
    assert_equal %(  @import "tailwindcss";\n@import "../builds/tailwind/geekofia_ui";\n), read("app/assets/tailwind/application.css")
  end

  private

  def write(path, content) = File.write(File.join(destination_root, path), content)
  def read(path) = File.read(File.join(destination_root, path))
end
