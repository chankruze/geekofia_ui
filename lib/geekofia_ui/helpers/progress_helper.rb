module GeekofiaUi
  module Helpers
    module ProgressHelper
      PROGRESS_TONES = { default: "bg-primary", success: "bg-success", warning: "bg-warning", destructive: "bg-destructive" }.freeze

      def ui_progress(value:, max: 100, tone: :default, **attrs)
        max_f = max.to_f
        val = value.to_f
        val = 0.0 unless val.finite?
        max_f = 0.0 unless max_f.finite?
        pct = max_f.positive? ? (val / max_f * 100).clamp(0.0, 100.0) : 0.0
        now = tidy(max_f.positive? ? val.clamp(0.0, max_f) : 0)
        top = tidy(max_f.positive? ? max_f : 100)
        bar = tag.div(class: "h-full rounded-full transition-all #{PROGRESS_TONES.fetch(ui_option!(:tone, tone, PROGRESS_TONES.keys))}",
                      style: "width: #{pct.round(1)}%")
        content_tag(:div, bar, class: ui_classes("h-2 w-full overflow-hidden rounded-full bg-muted", attrs.delete(:class)),
                    role: "progressbar", "aria-valuenow": now, "aria-valuemin": 0, "aria-valuemax": top,
                    "aria-valuetext": "#{pct.round}%", **attrs)
      end

      private

      def tidy(number) = number.to_f == number.to_i ? number.to_i : number.to_f
    end
  end
end
