require "geekofia_ui/helpers/support"

module GeekofiaUi
  # Mixed into ActionView::Base by the engine. Component modules are added
  # to this list as they are implemented.
  module Helpers
    include Support
  end
end
