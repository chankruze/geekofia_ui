module GeekofiaUi
  module Helpers
    module FeedbackHelper
      ALERT_VARIANTS = {
        info: "border-info/30 bg-info/10",
        success: "border-success/30 bg-success/10",
        warning: "border-warning/30 bg-warning/10",
        destructive: "border-destructive/30 bg-destructive/10"
      }.freeze
      ALERT_ICONS = { info: :info, success: :check_circle, warning: :alert_triangle, destructive: :alert_circle }.freeze
      ALERT_ICON_COLORS = { info: "text-info", success: "text-success", warning: "text-warning", destructive: "text-destructive" }.freeze
      FLASH_VARIANTS = { "notice" => :success, "alert" => :destructive, "warning" => :warning, "info" => :info }.freeze

      def ui_alert(title: nil, variant: :info, icon: :auto, **attrs, &block)
        v = ui_option!(:variant, variant, ALERT_VARIANTS.keys)
        body = block && capture(&block)
        return "".html_safe if title.blank? && body.blank?

        render(partial: "geekofia_ui/components/alert", formats: [ :html ],
               locals: {
                 title:, body:, icon: icon == :auto ? ALERT_ICONS[v] : icon,
                 icon_class: ALERT_ICON_COLORS[v],
                 css: ui_classes("relative flex gap-3 rounded-lg border px-4 py-3 text-sm text-foreground",
                                 ALERT_VARIANTS[v], attrs.delete(:class)),
                 attrs: { role: v == :destructive ? "alert" : "status" }.merge(attrs)
               })
      end

      def ui_flash
        safe_join(FLASH_VARIANTS.filter_map do |type, variant|
          messages = Array(flash[type]).select { |m| m.is_a?(String) && m.present? }
          next if messages.empty?

          ui_alert(variant:, class: "mb-4") { safe_join(messages, tag.br) }
        end)
      end
    end
  end
end
