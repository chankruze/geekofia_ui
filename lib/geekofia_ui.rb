require "geekofia_ui/version"
require "geekofia_ui/configuration"
require "geekofia_ui/class_merge"
require "geekofia_ui/icons"
require "geekofia_ui/fonts"
require "geekofia_ui/engine" if defined?(Rails::Engine)

module GeekofiaUi
  class << self
    def config = @config ||= Configuration.new
    def configure = yield(config)
    def reset_config! = @config = Configuration.new
  end
end
