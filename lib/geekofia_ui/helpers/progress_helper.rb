module GeekofiaUi
  module Helpers
    module ProgressHelper
      PROGRESS_TONES = { default: "bg-primary", success: "bg-success", warning: "bg-warning", destructive: "bg-destructive" }.freeze

      def ui_progress(value:, max: 100, tone: :default, **attrs)
        percent = max.to_f.positive? ? (value.to_f / max * 100).clamp(0.0, 100.0) : 0.0
        bar = tag.div(class: "h-full rounded-full transition-all #{PROGRESS_TONES.fetch(ui_option!(:tone, tone, PROGRESS_TONES.keys))}",
                      style: "width: #{percent.round(1)}%")
        content_tag(:div, bar, class: ui_classes("h-2 w-full overflow-hidden rounded-full bg-muted", attrs.delete(:class)),
                    role: "progressbar", "aria-valuenow": value, "aria-valuemin": 0, "aria-valuemax": max, **attrs)
      end
    end
  end
end
