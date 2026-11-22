module GeekofiaUi
  module Icons
    class FontAwesome < Base
      CSS = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css"
      MAP = {
        copy: "copy", check: "check", sun: "sun", moon: "moon", monitor: "desktop", info: "circle-info",
        alert_triangle: "triangle-exclamation", alert_circle: "circle-exclamation", check_circle: "circle-check",
        x: "xmark", plus: "plus", server: "server", terminal: "terminal", refresh: "rotate-right", pencil: "pencil",
        trash: "trash", external_link: "arrow-up-right-from-square", help: "circle-question", arrow_left: "arrow-left",
        log_out: "right-from-bracket", hard_drive: "hard-drive", key: "key", play: "play", plug: "plug"
      }.freeze

      def render(name, size:, css_class: nil, attrs: {})
        element(:i, {
          class: classes("fa-#{@config.font_awesome_style}", "fa-#{provider_name(name, MAP)}", "shrink-0", css_class),
          style: "font-size: #{size}px; width: #{size}px; text-align: center; line-height: 1"
        }.merge(attrs))
      end

      def head_tags
        if @config.font_awesome_kit
          %(<script src="#{ERB::Util.html_escape(@config.font_awesome_kit)}" crossorigin="anonymous"></script>).html_safe
        else
          %(<link rel="stylesheet" href="#{CSS}">).html_safe
        end
      end
    end
  end
end
