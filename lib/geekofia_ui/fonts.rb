require "cgi"
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

      FAMILY_PATTERN = /\A[\p{L}\p{N} _.'-]+\z/

      def stack(family, fallback)
        name = clean_family(family)
        name ? %("#{name}", #{fallback}) : fallback
      end

      # Strips a family and rejects anything that could break out of CSS or a URL.
      def clean_family(family)
        name = family.to_s.strip
        return nil if name.empty?
        raise ArgumentError, "invalid font family #{name.inspect}; use letters, numbers, spaces, _ . ' and -" unless FAMILY_PATTERN.match?(name)
        name
      end

      def families = [ @config.font_sans, @config.font_mono ].filter_map { |f| clean_family(f) }.uniq(&:downcase)

      def weights = Array(@config.font_weights).map(&:to_i).select(&:positive?).uniq.sort

      def link(href, nonce)
        ActionController::Base.helpers.tag.link(rel: "stylesheet", href: href, nonce: nonce)
      end

      def preconnect(href, nonce, crossorigin: false)
        ActionController::Base.helpers.tag.link(rel: "preconnect", href: href, crossorigin: ("anonymous" if crossorigin), nonce: nonce)
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
        suffix = weights.empty? ? "" : ":wght@#{weights.join(";")}"
        query = families.map { |f| "family=#{CGI.escape(f)}#{suffix}" }.join("&")
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
        suffix = weights.empty? ? "" : ":#{weights.join(",")}"
        query = families.map { |f| "#{f.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")}#{suffix}" }.join("|")
        ActionController::Base.helpers.safe_join([
          preconnect("https://fonts.bunny.net", nonce),
          link("https://fonts.bunny.net/css?family=#{query}&display=swap", nonce)
        ], "\n")
      end
    end
  end
end
