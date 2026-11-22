module GeekofiaUi
  module Icons
    class Base
      def initialize(config)
        @config = config
      end

      def head_tags(nonce: nil) = "".html_safe

      private

      # Aliases win (for Symbols and Strings alike). Otherwise only a Symbol is a
      # semantic name mapped by the provider; a String is a raw provider name.
      def provider_name(name, map)
        aliased = @config.icon_aliases[name.to_s.to_sym]
        return aliased.to_s if aliased
        name.is_a?(Symbol) ? map.fetch(name, name.to_s) : name.to_s
      end

      def element(tag, attributes, inner = "".html_safe)
        ActionController::Base.helpers.content_tag(tag, inner, attributes)
      end

      # Merges required classes, css_class and any class given in attrs.
      def merged_class(required, css_class, attrs)
        extra = attrs[:class] || attrs["class"]
        GeekofiaUi::ClassMerge.call(*required, css_class, extra)
      end

      def without_class(attrs) = attrs.except(:class, "class")

      def tag_attrs(base, required, css_class, attrs)
        base.merge(without_class(attrs)).merge(class: merged_class(required, css_class, attrs))
      end

      def script_tag(src, nonce, **extra)
        ActionController::Base.helpers.content_tag(:script, "".html_safe, { src: src, nonce: nonce }.merge(extra))
      end

      def stylesheet_tag(href, nonce)
        ActionController::Base.helpers.tag.link(rel: "stylesheet", href: href, nonce: nonce)
      end
    end
  end
end
