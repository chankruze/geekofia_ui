module GeekofiaUi
  module Icons
    class Lucide < Base
      DIR = File.expand_path("lucide", __dir__)
      NAME = /\A[a-z0-9-]+\z/

      SVGS = Dir[File.join(DIR, "*.svg")].to_h do |path|
        inner = File.read(path)[%r{<svg[^>]*>(.*)</svg>}m, 1].to_s.strip
        [ File.basename(path, ".svg"), inner.html_safe ]
      end.freeze

      def render(name, size:, css_class: nil, attrs: {})
        file = provider_name(name, LUCIDE_NAMES)
        inner = SVGS[file] if file.match?(NAME)
        return missing(name, file) unless inner

        element(:svg, tag_attrs({
          xmlns: "http://www.w3.org/2000/svg", width: size, height: size, viewBox: "0 0 24 24",
          fill: "none", stroke: "currentColor", "stroke-width": 2, "stroke-linecap": "round",
          "stroke-linejoin": "round"
        }, %w[shrink-0], css_class, attrs), inner)
      end

      private

      def missing(name, file)
        message = "unknown lucide icon #{name.inspect} (resolved to #{file.inspect})"
        raise ArgumentError, message if !defined?(Rails) || Rails.env.local?
        Rails.logger&.warn(message)
        "".html_safe
      end
    end
  end
end
