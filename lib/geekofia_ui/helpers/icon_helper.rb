module GeekofiaUi
  module Helpers
    module IconHelper
      def ui_icon(name, size: 16, aria_label: nil, **attrs)
        css = attrs.delete(:class)
        a = attrs.dup
        if aria_label
          a[:role] = "img"
          a[:"aria-label"] = aria_label
        else
          a[:"aria-hidden"] = "true"
        end
        GeekofiaUi.config.icons.render(name, size:, css_class: css, attrs: a)
      end
    end
  end
end
