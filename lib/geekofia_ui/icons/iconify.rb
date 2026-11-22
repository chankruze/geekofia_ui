module GeekofiaUi
  module Icons
    class Iconify < Base
      SCRIPT = "https://code.iconify.design/iconify-icon/2.3.0/iconify-icon.min.js"

      def render(name, size:, css_class: nil, attrs: {})
        element(:"iconify-icon", { icon: icon_name(name), width: size, height: size,
                                   class: classes("shrink-0", css_class) }.merge(attrs))
      end

      def head_tags = %(<script src="#{SCRIPT}"></script>).html_safe

      private

      def icon_name(name)
        key = name.to_s.to_sym
        return qualify(@config.icon_aliases[key].to_s) if @config.icon_aliases[key]
        return "lucide:#{LUCIDE_NAMES[key]}" if name.is_a?(Symbol) && LUCIDE_NAMES.key?(key)
        qualify(name.to_s)
      end

      def qualify(name) = name.include?(":") ? name : "#{@config.icon_set}:#{name}"
    end
  end
end
