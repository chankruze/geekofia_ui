# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"

require "nokogiri"

module GeekofiaUi::TestHelpers
  def fragment(html) = Nokogiri::HTML5.fragment(html.to_s)
end

ActiveSupport.on_load(:active_support_test_case) do
  include GeekofiaUi::TestHelpers
  teardown { GeekofiaUi.reset_config! }
end
