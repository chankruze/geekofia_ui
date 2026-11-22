module GeekofiaUi
  module Icons
    class Iconify < Base
      SCRIPT = "https://code.iconify.design/iconify-icon/2.3.0/iconify-icon.min.js"
      MAP = LUCIDE_NAMES.transform_values { |v| "lucide:#{v}" }.freeze

      def render(name, size:, css_class: nil, attrs: {})
        icon = qualify(provider_name(name, MAP))
        element(:"iconify-icon", tag_attrs({ icon: icon, width: size, height: size }, %w[shrink-0], css_class, attrs))
      end

      def head_tags(nonce: nil) = script_tag(SCRIPT, nonce)

      private

      def qualify(name) = name.include?(":") ? name : "#{@config.icon_set}:#{name}"
    end
  end
end
