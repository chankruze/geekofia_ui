module GeekofiaUi
  module Helpers
    module ConfirmHelper
      def ui_confirm_dialog
        render(partial: "geekofia_ui/components/confirm_dialog", formats: [ :html ],
               locals: { default_class: ButtonHelper::BUTTON_VARIANTS[:default],
                         destructive_class: ButtonHelper::BUTTON_VARIANTS[:destructive] })
      end

      private

      # data-* attributes understood by the ui-confirm controller.
      def ui_confirm_data(confirm)
        return {} if confirm.blank?
        confirm = { message: confirm } if confirm.is_a?(String)
        data = { turbo_confirm: confirm.fetch(:message) { raise ArgumentError, "confirm: needs a message" } }
        data[:confirm_title] = confirm[:title] if confirm[:title]
        data[:confirm_button] = confirm[:button] if confirm[:button]
        data[:confirm_variant] = ui_option!(:confirm_variant, confirm[:variant], %i[default destructive]) if confirm[:variant]
        data
      end
    end
  end
end
