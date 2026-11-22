require "erb"
require "active_support/core_ext/string/output_safety"

module GeekofiaUi
  module Icons
    SEMANTIC = %i[copy check sun moon monitor info alert_triangle alert_circle check_circle x plus server
                  terminal refresh pencil trash external_link help arrow_left log_out hard_drive key play plug].freeze

    LUCIDE_NAMES = {
      copy: "copy", check: "check", sun: "sun", moon: "moon", monitor: "monitor", info: "info",
      alert_triangle: "triangle-alert", alert_circle: "circle-alert", check_circle: "circle-check", x: "x",
      plus: "plus", server: "server", terminal: "terminal", refresh: "refresh-cw", pencil: "pencil",
      trash: "trash-2", external_link: "external-link", help: "circle-help", arrow_left: "arrow-left",
      log_out: "log-out", hard_drive: "hard-drive", key: "key-round", play: "play", plug: "plug"
    }.freeze

    BUILT_IN = { lucide: "Lucide", iconify: "Iconify", font_awesome: "FontAwesome", material_symbols: "MaterialSymbols" }.freeze

    def self.resolve(provider, config)
      return provider unless provider.is_a?(Symbol) || provider.is_a?(String)
      class_name = BUILT_IN.fetch(provider.to_sym) do
        raise ArgumentError, "unknown icon_provider #{provider.inspect}; use one of #{BUILT_IN.keys.join(", ")} or an object"
      end
      const_get(class_name).new(config)
    end
  end
end

require "geekofia_ui/icons/base"
require "geekofia_ui/icons/lucide"
require "geekofia_ui/icons/iconify"
require "geekofia_ui/icons/font_awesome"
require "geekofia_ui/icons/material_symbols"
