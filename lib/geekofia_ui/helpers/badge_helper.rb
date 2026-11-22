module GeekofiaUi
  module Helpers
    module BadgeHelper
      BADGE_VARIANTS = {
        default: "border-transparent bg-primary text-primary-foreground",
        secondary: "border-transparent bg-secondary text-secondary-foreground",
        success: "border-transparent bg-success/15 text-success",
        warning: "border-transparent bg-warning/15 text-warning",
        destructive: "border-transparent bg-destructive/15 text-destructive",
        info: "border-transparent bg-info/15 text-info",
        outline: "border-border text-foreground"
      }.freeze

      def ui_badge(text = nil, variant: :default, dot: false, **attrs, &block)
        classes = ui_classes("inline-flex items-center gap-1.5 whitespace-nowrap rounded-md border px-2 py-0.5 text-xs font-medium",
                             BADGE_VARIANTS.fetch(ui_option!(:variant, variant, BADGE_VARIANTS.keys)), attrs.delete(:class))
        dot_tag = tag.span(class: "size-1.5 rounded-full bg-current", aria: { hidden: true }) if dot
        content_tag(:span, safe_join([ dot_tag, (block ? capture(&block) : text) ].compact), class: classes, **attrs)
      end
    end
  end
end
