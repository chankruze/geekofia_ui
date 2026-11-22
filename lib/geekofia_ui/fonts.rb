require "active_support/core_ext/string/output_safety"

module GeekofiaUi
  module Fonts
    SANS_STACK = 'ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'
    MONO_STACK = 'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace'
    BUILT_IN = { system: "System", google: "Google", bunny: "Bunny", self_hosted: "SelfHosted" }.freeze

    def self.resolve(provider, config)
      return provider unless provider.is_a?(Symbol) || provider.is_a?(String)
      class_name = BUILT_IN.fetch(provider.to_sym) do
        raise ArgumentError, "unknown font_provider #{provider.inspect}; use one of #{BUILT_IN.keys.join(", ")} or an object"
      end
      const_get(class_name).new(config)
    end

    class Base
      def initialize(config)
        @config = config
      end

      def head_tags(nonce: nil) = "".html_safe

      def stacks
        { sans: stack(@config.font_sans, SANS_STACK), mono: stack(@config.font_mono, MONO_STACK) }
      end

      private

      def stack(family, fallback)
        family.to_s.strip.empty? ? fallback : %("#{family.to_s.delete('"<>')}", #{fallback})
      end

      def families = [ @config.font_sans, @config.font_mono ].map(&:to_s).map(&:strip).reject(&:empty?).uniq

      def link(href, nonce)
        ActionController::Base.helpers.tag.link(rel: "stylesheet", href: href, nonce: nonce)
      end

      def preconnect(href, nonce, crossorigin: false)
        ActionController::Base.helpers.tag.link(rel: "preconnect", href: href, crossorigin: (true if crossorigin), nonce: nonce)
      end
    end

    class System < Base
      def stacks = { sans: SANS_STACK, mono: MONO_STACK }
    end

    class SelfHosted < Base
    end

    class Google < Base
      def head_tags(nonce: nil)
        return "".html_safe if families.empty?
        query = families.map { |f| "family=#{f.tr(" ", "+")}:wght@#{@config.font_weights.join(";")}" }.join("&")
        ActionController::Base.helpers.safe_join([
          preconnect("https://fonts.googleapis.com", nonce),
          preconnect("https://fonts.gstatic.com", nonce, crossorigin: true),
          link("https://fonts.googleapis.com/css2?#{query}&display=swap", nonce)
        ], "\n")
      end
    end

    class Bunny < Base
      def head_tags(nonce: nil)
        return "".html_safe if families.empty?
        query = families.map { |f| "#{f.downcase.tr(" ", "-")}:#{@config.font_weights.join(",")}" }.join("|")
        ActionController::Base.helpers.safe_join([
          preconnect("https://fonts.bunny.net", nonce),
          link("https://fonts.bunny.net/css?family=#{query}&display=swap", nonce)
        ], "\n")
      end
    end
  end
end
