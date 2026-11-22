module GeekofiaUi
  module Helpers
    module ThemeHelper
      THEME_SCRIPT = <<~JS.squish
        (function(){var k="geekofia-ui-theme",m=window.matchMedia("(prefers-color-scheme: dark)");
        function a(t){var s;try{s=localStorage.getItem(k)}catch(e){}t=t||s||"system";
        var d=t==="dark"||(t==="system"&&m.matches),r=document.documentElement;
        r.classList.toggle("dark",d);r.style.colorScheme=d?"dark":"light"}
        window.GeekofiaUI={applyTheme:a,storageKey:k};a();function f(){a()}m.addEventListener?m.addEventListener("change",f):m.addListener(f);
        document.addEventListener("turbo:load",f)})();
      JS

      def ui_theme_toggle(**attrs)
        render(partial: "geekofia_ui/components/theme_toggle", formats: [ :html ], locals: { attrs: })
      end

      def ui_head_tags
        nonce = respond_to?(:content_security_policy_nonce, true) ? content_security_policy_nonce : nil
        fonts = GeekofiaUi.config.fonts
        stacks = fonts.stacks
        css = ":root{--ui-font-sans:#{stacks[:sans]};--ui-font-mono:#{stacks[:mono]}}".delete("<>")
        safe_join([
          javascript_tag(THEME_SCRIPT.html_safe, nonce: nonce),
          content_tag(:style, css.html_safe, nonce: nonce),
          ui_provider_head_tags(fonts, nonce),
          ui_provider_head_tags(GeekofiaUi.config.icons, nonce)
        ], "\n")
      end

      private

      def ui_provider_head_tags(provider, nonce)
        accepts_nonce = provider.method(:head_tags).parameters.any? do |type, name|
          type == :keyrest || (%i[key keyreq].include?(type) && name == :nonce)
        end
        accepts_nonce ? provider.head_tags(nonce:) : provider.head_tags
      end
    end
  end
end
