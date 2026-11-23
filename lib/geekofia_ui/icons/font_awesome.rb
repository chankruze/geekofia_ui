module GeekofiaUi
  module Icons
    class FontAwesome < Base
      CSS = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css"
      MAP = {
        copy: "copy", check: "check", sun: "sun", moon: "moon", monitor: "desktop", info: "circle-info",
        alert_triangle: "triangle-exclamation", alert_circle: "circle-exclamation", check_circle: "circle-check",
        x: "xmark", plus: "plus", server: "server", terminal: "terminal", refresh: "rotate-right", pencil: "pencil",
        trash: "trash", external_link: "arrow-up-right-from-square", help: "circle-question", arrow_left: "arrow-left",
        log_out: "right-from-bracket", hard_drive: "hard-drive", key: "key", play: "play", plug: "plug", more: "ellipsis"
      }.freeze

      def render(name, size:, css_class: nil, attrs: {})
        required = [ "fa-#{@config.font_awesome_style}", "fa-#{provider_name(name, MAP)}", "shrink-0" ]
        element(:i, tag_attrs({
          style: "font-size: #{size}px; width: #{size}px; text-align: center; line-height: 1"
        }, required, css_class, attrs))
      end

      def head_tags(nonce: nil)
        if @config.font_awesome_kit
          script_tag(@config.font_awesome_kit, nonce, crossorigin: "anonymous")
        else
          stylesheet_tag(CSS, nonce)
        end
      end
    end
  end
end
