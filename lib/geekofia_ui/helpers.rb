require "geekofia_ui/helpers/support"
require "geekofia_ui/helpers/icon_helper"
require "geekofia_ui/helpers/button_helper"
require "geekofia_ui/helpers/badge_helper"
require "geekofia_ui/helpers/progress_helper"

module GeekofiaUi
  # Mixed into ActionView::Base by the engine.
  module Helpers
    include Support
    include IconHelper
    include ButtonHelper
    include BadgeHelper
    include ProgressHelper
  end
end
