require "importmap-rails"
require "tailwindcss-rails"
require "stimulus-rails"

module GeekofiaUi
  class Engine < ::Rails::Engine
    engine_name "geekofia_ui"

    initializer "geekofia_ui.helpers" do
      ActiveSupport.on_load(:action_view) { include GeekofiaUi::Helpers }
    end

    initializer "geekofia_ui.assets" do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.paths << root.join("app/javascript")
      # Raw engine.css is a Tailwind input, not something to serve.
      app.config.assets.excluded_paths << root.join("app/assets/tailwind") if app.config.assets.respond_to?(:excluded_paths)
    end

    initializer "geekofia_ui.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end
  end
end
