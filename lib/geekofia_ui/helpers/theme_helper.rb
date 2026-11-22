module GeekofiaUi
  module Helpers
    module ThemeHelper
      THEME_SCRIPT = <<~JS.squish
        (function(){var k="geekofia-ui-theme",m=window.matchMedia("(prefers-color-scheme: dark)");
        function a(t){var s;try{s=localStorage.getItem(k)}catch(e){}t=t||s||"system";
        var d=t==="dark"||(t==="system"&&m.matches),r=document.documentElement;
        r.classList.toggle("dark",d);r.style.colorScheme=d?"dark":"light"}
        window.GeekofiaUI={applyTheme:a,storageKey:k};a();m.addEventListener("change",function(){a()});
        document.addEventListener("turbo:load",function(){a()})})();
      JS

      def ui_theme_toggle(**attrs)
        render(partial: "geekofia_ui/components/theme_toggle", formats: [ :html ], locals: { attrs: })
      end

      def ui_head_tags
        fonts = GeekofiaUi.config.fonts
        stacks = fonts.stacks
        css = ":root{--ui-font-sans:#{stacks[:sans]};--ui-font-mono:#{stacks[:mono]}}".delete("<>")
        safe_join([
          javascript_tag(THEME_SCRIPT.html_safe, nonce: true),
          content_tag(:style, css.html_safe, nonce: content_security_policy_nonce),
          ui_provider_head_tags(fonts),
          ui_provider_head_tags(GeekofiaUi.config.icons)
        ], "\n")
      end

      private

      def ui_provider_head_tags(provider)
        accepts_nonce = provider.method(:head_tags).parameters.any? { |type, name| name == :nonce || type == :keyrest }
        accepts_nonce ? provider.head_tags(nonce: content_security_policy_nonce) : provider.head_tags
      end
    end
  end
end
