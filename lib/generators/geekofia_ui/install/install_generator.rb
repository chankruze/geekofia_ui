require "rails/generators"

module GeekofiaUi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Wire geekofia_ui into this app: Tailwind import, Stimulus controllers, initializer, head tags."

      CSS_FILE = "app/assets/tailwind/application.css"
      CSS_IMPORT = %(@import "../builds/tailwind/geekofia_ui";)
      JS_FILE = "app/javascript/controllers/index.js"
      JS_LINE = %(eagerLoadControllersFrom("geekofia_ui/controllers", application))
      LAYOUT = "app/views/layouts/application.html.erb"

      TAILWIND_IMPORT = /^@import\s+["']tailwindcss["'][^;\n]*;?[ \t]*(\r?\n|\z)/
      STYLESHEET_TAG = /^[ \t]*<%=\s*stylesheet_link_tag/

      def add_tailwind_import
        return skip(CSS_FILE) unless exist?(CSS_FILE)
        return identical(CSS_FILE) if read(CSS_FILE).include?(CSS_IMPORT)
        match = read(CSS_FILE).match(TAILWIND_IMPORT)
        return say_status(:skip, %(add #{CSS_IMPORT} after @import "tailwindcss" in #{CSS_FILE}), :yellow) unless match
        text = match[0].match?(/\n\z/) ? "#{CSS_IMPORT}\n" : "\n#{CSS_IMPORT}\n"
        inject_into_file CSS_FILE, text, after: TAILWIND_IMPORT
      end

      def register_controllers
        return skip(JS_FILE) unless exist?(JS_FILE)
        content = read(JS_FILE)
        return identical(JS_FILE) if content.include?(JS_LINE)
        append_to_file JS_FILE, "#{"\n" unless content.end_with?("\n")}#{JS_LINE}\n"
      end

      def create_initializer
        copy_file "geekofia_ui.rb", "config/initializers/geekofia_ui.rb", skip: true
      end

      def add_head_tags
        return skip(LAYOUT) unless exist?(LAYOUT)
        content = read(LAYOUT)
        return identical(LAYOUT) if content.include?("ui_head_tags")
        return say_status(:skip, "add <%= ui_head_tags %> inside <head> of #{LAYOUT}", :yellow) unless content.match?(STYLESHEET_TAG)
        inject_into_file LAYOUT, "    <%= ui_head_tags %>\n", before: STYLESHEET_TAG
      end

      private

      def exist?(path) = File.exist?(File.join(destination_root, path))
      def read(path) = File.read(File.join(destination_root, path))
      def identical(path) = say_status(:identical, path, :blue)
      def skip(path) = say_status(:skip, "#{path} not found", :yellow)
    end
  end
end
