require "geekofia_ui/helpers/support"
require "geekofia_ui/helpers/icon_helper"
require "geekofia_ui/helpers/button_helper"
require "geekofia_ui/helpers/badge_helper"
require "geekofia_ui/helpers/progress_helper"
require "geekofia_ui/helpers/layout_helper"
require "geekofia_ui/helpers/table_helper"
require "geekofia_ui/helpers/feedback_helper"
require "geekofia_ui/helpers/copy_helper"
require "geekofia_ui/helpers/steps_helper"
require "geekofia_ui/helpers/theme_helper"
require "geekofia_ui/helpers/confirm_helper"
require "geekofia_ui/helpers/dropdown_helper"
require "geekofia_ui/helpers/tabs_helper"

module GeekofiaUi
  # Mixed into ActionView::Base by the engine.
  module Helpers
    include Support
    include IconHelper
    include ButtonHelper
    include BadgeHelper
    include ProgressHelper
    include LayoutHelper
    include TableHelper
    include FeedbackHelper
    include CopyHelper
    include StepsHelper
    include ThemeHelper
    include ConfirmHelper
    include DropdownHelper
    include TabsHelper
  end
end
