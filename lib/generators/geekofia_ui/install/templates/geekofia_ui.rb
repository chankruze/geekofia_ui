# geekofia_ui configuration. Restart the server after changes.
GeekofiaUi.configure do |c|
  # Icons: :lucide (bundled inline SVG, default), :iconify, :font_awesome, :material_symbols,
  # or any object responding to:
  #   render(name, size:, css_class:, attrs:)
  #   head_tags(nonce: nil)   # the nonce keyword is optional; providers that
  #                           # don't accept it are called without it
  # c.icon_provider = :lucide
  # c.icon_set = "lucide"   # iconify only: default set for raw String names without "set:"
  # Semantic icon names are Symbols (ui_icon(:copy)). Strings are raw provider names.
  # Assign a new hash; the defaults are frozen, so don't mutate them in place.
  # c.icon_aliases = { copy: "clipboard" } # semantic name => provider icon name
  # c.font_awesome_kit = "https://kit.fontawesome.com/xxxx.js"
  # c.font_awesome_style = "solid"

  # Fonts: :system (default), :google, :bunny, :self_hosted, or an object responding to
  # head_tags(nonce: nil) and stacks.
  # c.font_provider = :bunny
  # Family names may only contain letters, digits, spaces, and _ . ' - (anything else raises).
  # c.font_sans = "Inter"
  # c.font_mono = "JetBrains Mono"
  # Assign a new array; the default is frozen.
  # c.font_weights = [400, 500, 600, 700]
end

# Let GeekofiaUi::FormBuilder show errors itself instead of Rails wrapping
# invalid fields in <div class="field_with_errors">.
ActionView::Base.field_error_proc = proc { |html_tag, _instance| html_tag }
