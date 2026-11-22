module GeekofiaUi
  module Icons
    class Lucide < Base
      DIR = File.expand_path("lucide", __dir__)
      NAME = /\A[a-z0-9-]+\z/

      def self.inner_svg(file)
        @cache ||= {}
        @cache.fetch(file) do
          path = File.join(DIR, "#{file}.svg")
          @cache[file] = File.exist?(path) ? File.read(path)[%r{<svg[^>]*>(.*)</svg>}m, 1]&.strip : nil
        end
      end

      def render(name, size:, css_class: nil, attrs: {})
        file = provider_name(name, LUCIDE_NAMES)
        inner = self.class.inner_svg(file) if file.match?(NAME)
        return missing(name) unless inner

        element(:svg, {
          xmlns: "http://www.w3.org/2000/svg", width: size, height: size, viewBox: "0 0 24 24",
          fill: "none", stroke: "currentColor", "stroke-width": 2, "stroke-linecap": "round",
          "stroke-linejoin": "round", class: classes("shrink-0", css_class)
        }.merge(attrs), inner)
      end

      private

      def missing(name)
        raise ArgumentError, "unknown lucide icon #{name.inspect}" if !defined?(Rails) || Rails.env.local?
        "".html_safe
      end
    end
  end
end
