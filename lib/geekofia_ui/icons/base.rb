module GeekofiaUi
  module Icons
    class Base
      def initialize(config)
        @config = config
      end

      def head_tags = "".html_safe

      private

      # Alias first, then the provider's semantic map, otherwise the name as given.
      def provider_name(name, map)
        key = name.to_s.to_sym
        aliased = @config.icon_aliases[key]
        return aliased.to_s if aliased
        map.fetch(key, name.to_s)
      end

      def element(tag, attributes, inner = "")
        attrs = attributes.compact.map { |k, v| %(#{k}="#{ERB::Util.html_escape(v)}") }.join(" ")
        "<#{tag} #{attrs}>#{inner}</#{tag}>".html_safe
      end

      def classes(*parts) = parts.compact.join(" ")
    end
  end
end
