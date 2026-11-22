module GeekofiaUi
  module Icons
    class MaterialSymbols < Base
      CSS = "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"
      MAP = {
        copy: "content_copy", check: "check", sun: "light_mode", moon: "dark_mode", monitor: "desktop_windows",
        info: "info", alert_triangle: "warning", alert_circle: "error", check_circle: "check_circle", x: "close",
        plus: "add", server: "dns", terminal: "terminal", refresh: "refresh", pencil: "edit", trash: "delete",
        external_link: "open_in_new", help: "help", arrow_left: "arrow_back", log_out: "logout",
        hard_drive: "hard_drive", key: "key", play: "play_arrow", plug: "power"
      }.freeze

      def render(name, size:, css_class: nil, attrs: {})
        element(:span, {
          class: classes("material-symbols-outlined", "shrink-0", css_class),
          style: "font-size: #{size}px; width: #{size}px; height: #{size}px; overflow: hidden; line-height: 1"
        }.merge(attrs), ERB::Util.html_escape(provider_name(name, MAP)))
      end

      def head_tags = %(<link rel="stylesheet" href="#{ERB::Util.html_escape(CSS)}">).html_safe
    end
  end
end
