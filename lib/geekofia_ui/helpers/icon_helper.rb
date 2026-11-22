module GeekofiaUi
  module Helpers
    module IconHelper
      def ui_icon(name, size: 16, aria_label: nil, **attrs)
        css = attrs.delete(:class)
        a = attrs.dup
        nested = a[:aria].is_a?(Hash) ? a[:aria].dup : nil
        aria_label ||= nested&.delete(:label)
        aria_label ||= a.delete(:"aria-label") || a.delete("aria-label")
        a.delete(:"aria-label")
        a.delete("aria-label")
        if nested
          nested.empty? ? a.delete(:aria) : a[:aria] = nested
        end
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
