module GeekofiaUi
  module Helpers
    module ButtonHelper
      BUTTON_BASE = "inline-flex cursor-pointer items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm " \
                    "font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
                    "focus-visible:ring-offset-2 focus-visible:ring-offset-background disabled:pointer-events-none disabled:opacity-50"
      BUTTON_VARIANTS = {
        default: "bg-primary text-primary-foreground shadow-sm hover:bg-primary/90",
        secondary: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80",
        outline: "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        destructive: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90",
        link: "text-primary underline-offset-4 hover:underline"
      }.freeze
      BUTTON_SIZES = { sm: "h-8 px-3 text-xs", md: "h-9 px-4 py-2", lg: "h-10 px-6", icon: "size-9" }.freeze

      def ui_button(label = nil, href: nil, method: nil, variant: :default, size: :md, icon: nil, form: {}, form_class: "inline-flex", params: nil, **attrs, &block)
        classes = ui_classes(BUTTON_BASE,
                             BUTTON_VARIANTS.fetch(ui_option!(:variant, variant, BUTTON_VARIANTS.keys)),
                             BUTTON_SIZES.fetch(ui_option!(:size, size, BUTTON_SIZES.keys)),
                             attrs.delete(:class))
        body = safe_join([ (ui_icon(icon) if icon), (block ? capture(&block) : label) ].compact)

        verb = method&.to_s&.downcase
        if href.nil?
          content_tag(:button, body, type: attrs.delete(:type) || "button", class: classes, **attrs)
        elsif verb.nil? || verb == "get"
          href = "#{href}#{href.include?("?") ? "&" : "?"}#{params.to_query}" if params.present?
          link_to(body, href, class: classes, **attrs)
        else
          button_to(href, method: verb.to_sym, class: classes, form:, form_class:, params:, **attrs) { body }
        end
      end
    end
  end
end
