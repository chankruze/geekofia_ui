module GeekofiaUi
  class Engine < ::Rails::Engine
    engine_name "geekofia_ui"

    initializer "geekofia_ui.helpers" do
      ActiveSupport.on_load(:action_view) { include GeekofiaUi::Helpers }
    end

    initializer "geekofia_ui.assets" do |app|
      app.config.assets.paths << root.join("app/javascript") if app.config.respond_to?(:assets)
    end

    initializer "geekofia_ui.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end
  end
end
