# geekofia_ui

shadcn-style UI components for Rails ERB + Tailwind CSS v4 apps: `ui_*` helpers backed by partials,
a form builder, Stimulus controllers for copy-to-clipboard and theme switching, light/dark mode with
a toggle, and pluggable icon and font providers.

## Install

```ruby
# Gemfile
gem "geekofia_ui", github: "chankruze/geekofia_ui", tag: "v0.2.0"
```

```sh
bundle install
bin/rails g geekofia_ui:install   # Tailwind import, Stimulus registration, initializer, ui_head_tags, ui_confirm_dialog
bin/rails tailwindcss:build
```

Requires Ruby >= 3.3, Rails 8+ (< 9), Propshaft, tailwindcss-rails 4.2+, importmap-rails and stimulus-rails.

The install generator also sets `ActionView::Base.field_error_proc` in the initializer. This is global to the app:
Rails no longer wraps invalid fields in `<div class="field_with_errors">` anywhere, because the form builder
renders errors itself.

### Layout

Put `ui_head_tags` in `<head>` **before** the stylesheet tag:

```erb
<head>
  <%= ui_head_tags %>
  <%= stylesheet_link_tag :app %>
</head>
```

It emits the pre-paint theme script (so there is no flash of the wrong theme), the font CSS variables,
and any icon/font provider tags. It honors the CSP nonce when one is available.

## Components

| Helper | Example |
|---|---|
| `ui_button` | `ui_button("Save", variant: :default, size: :md, icon: :check)` |
| `ui_badge` | `ui_badge("ok", variant: :success, dot: true)` |
| `ui_card` | see below |
| `ui_page_header` | see below |
| `ui_empty_state` | see below |
| `ui_table` | see below |
| `ui_progress` | `ui_progress(value: 42, tone: :warning)` |
| `ui_alert` / `ui_flash` | see below; put `ui_flash` in the layout |
| `ui_copy_button` | `ui_copy_button("text")` or `ui_copy_button(source: "#log")` |
| `ui_code_block` | `ui_code_block(cmd, wrap: true, copy: true, copy_label: "Copy", language: :sh)` |
| `ui_steps` | see below |
| `ui_theme_toggle` | cycles light, dark, then system |
| `ui_dropdown_menu` | see [Dropdown menu](#dropdown-menu) |
| `ui_tabs` | see [Tabs](#tabs) |
| `ui_confirm_dialog` | see [Confirm dialog](#confirm-dialog); render once before `</body>` |
| `ui_icon` | `ui_icon(:copy, size: 16, aria_label: nil)`; `size` goes through `Integer()` and raises if invalid |

```erb
<%= ui_page_header(title: "Servers", description: "Office LAN", badge: ui_badge("ok"), title_tag: :h1) do %>
  <%= ui_button "Add", icon: :plus %>
<% end %>

<%= ui_empty_state(title: "No servers", description: "Add one to begin", icon: :server) do %>
  <%= ui_button "Add" %>
<% end %>

<%= ui_alert(title: "Heads up", variant: :warning) do %>
  Something to know.
<% end %>

<%= ui_card do |c| %>
  <%= c.header(title: "Disks", description: "Mounted volumes") { ui_button "Refresh" } %>
  <%= c.content do %>
    <%= ui_table do |t| %>
      <%= t.head { |r| safe_join([ r.cell("Name"), r.cell("Usage") ]) } %>
      <%= t.body do %>
        <%= t.row { |r| safe_join([ r.cell("/"), r.cell { ui_progress(value: 45) } ]) } %>
      <% end %>
    <% end %>
  <% end %>
  <%= c.footer { "Updated just now" } %>
<% end %>

<%= ui_steps do |s| %>
  <%= s.step(title: "Copy key", done: true) { "Paste it on the server" } %>
  <%= s.step(title: "Test connection") %>
<% end %>
```

`ui_page_header`, `ui_empty_state`, `c.header` and `s.step` also take `class:` and HTML attributes, applied to
their root element.

Every helper accepts `class:` (merged; later utilities win) and passes other HTML attributes through.
Variants and sizes are validated and raise `ArgumentError` listing the allowed values.

### Buttons

- `ui_button "Open", href: path` renders a link. With `params:`, they are appended to the query string.
- Any `method:` other than GET renders `button_to`: `ui_button "Delete", href: path, method: :delete, params: { id: 1 }`.
  `params:` become hidden inputs, `form:` sets attributes on the form, and `form_class` defaults to `inline-flex`.

- `confirm:` asks before acting, via the [confirm dialog](#confirm-dialog). It takes a String or
  `{ message:, title:, button:, variant: }` (`variant: :destructive` styles the confirm button).
  `ui_button "Delete", href: path, method: :delete, confirm: { message: "Delete it?", title: "Delete", button: "Delete", variant: :destructive }`.
  The older `form: { data: { turbo_confirm: "..." } }` still works. Turbo only confirms form submissions, so on a plain
  `<button>` (no `href:`) use `type: "submit"` inside a form.

### Dropdown menu

```erb
<%= ui_dropdown_menu(label: "Server actions", icon: :more, align: :end) do |m| %>
  <%= m.item "Open", href: server_path(@server), icon: :external_link %>
  <%= m.item "Refresh", href: refresh_server_path(@server), method: :post, params: { full: 1 }, icon: :refresh %>
  <%= m.separator %>
  <%= m.item "Delete", href: server_path(@server), method: :delete, variant: :destructive, icon: :trash,
        confirm: { message: "Delete this server?", title: "Delete server", button: "Delete", variant: :destructive } %>
<% end %>
```

- Options: `label:` is the trigger's accessible name (default `"More actions"`), `icon:` the trigger icon (default `:more`),
  `align:` is `:end` (default, menu right-aligned to the trigger) or `:start`. `class:` and HTML attributes go on the root element.
- `m.item label, href:` takes `method:` (non-GET renders a `button_to` form), `params:` (query string for GET, hidden inputs otherwise),
  `icon:`, `variant: :default | :destructive` and `confirm:` (non-GET items only, as for `ui_button`).
- Keyboard: Enter, Space or Down on the trigger opens the menu (Up opens on the last item). Up, Down, Home and End move between items.
  Escape closes and returns focus to the trigger. Tab and an outside click close it. Activating an item closes the menu and returns focus to the trigger.
- It needs JavaScript: the menu is `hidden` until the Stimulus `ui-dropdown` controller connects.

### Tabs

```erb
<%= ui_tabs label: "Server sections" do |t| %>
  <%= t.tab "Overview", href: "/servers/1" %>
  <%= t.tab "Packages", href: "/servers/1/packages", match: :prefix, badge: 3, badge_variant: :destructive %>
  <%= t.tab "Storage", href: "/servers/1/storage", dot: :warning, dot_label: "health warning" %>
<% end %>
```

- `ui_tabs label:` is the nav landmark name (required). `class:` and HTML attributes go on the `<nav>`.
- `t.tab label, href:` takes `active:` (true or false overrides the computed state), `match: :exact | :prefix` (default `:exact`;
  `:prefix` also matches sub-paths), `badge:` (nil and 0 render nothing), `badge_variant:` (any `ui_badge` variant, default `:secondary`),
  `dot: :success | :warning | :destructive`, `dot_label:` (screen-reader text, default `"attention"`) and extra HTML attributes.
- The active tab gets `aria-current="page"`; inactive tabs have no `aria-current` attribute. The bar scrolls horizontally when it overflows.
- No JavaScript: tabs are plain links.

### Confirm dialog

Render `ui_confirm_dialog` exactly once, just before `</body>` (the install generator inserts it):

```erb
    <%= ui_confirm_dialog %>
  </body>
```

It replaces Turbo's `window.confirm` for every `data-turbo-confirm` (links, forms and buttons) by setting
`Turbo.config.forms.confirm`. This needs Turbo 8 / turbo-rails 2 and the `@hotwired/turbo-rails` importmap pin in the host app.
Without the dialog on the page, or on an older Turbo, the native confirm is used.

Optional attributes customize the dialog: `data-confirm-title` (default "Are you sure?"), `data-confirm-button` (default "Confirm")
and `data-confirm-variant="destructive"` (red confirm button). They are read from the submitter, then the element Turbo confirms,
then the clicked `data-turbo-confirm` link. Cancel, Escape and a backdrop click all mean "no".

### Flash

`ui_flash` renders only the `notice`, `alert`, `warning` and `info` keys.

### Code blocks

`ui_code_block` takes `wrap:` (wrap long lines), `copy:` (show the copy button), `copy_label:` and
`language:` (adds a `language-*` class to the `<code>` element).

### Copy button

`ui_copy_button` renders a wrapper span around the button. `data:` goes on the wrapper (where the Stimulus
controller lives) and `class:` goes on the button.

### Forms

```erb
<%= form_with model: @thing, builder: GeekofiaUi::FormBuilder do |f| %>
  <%= f.ui_text_field :name, hint: "A hint" %>
  <%= f.ui_submit "Save" %>
<% end %>
```

Fields: `ui_text_field`, `ui_email_field`, `ui_password_field`, `ui_number_field`, `ui_text_area`,
`ui_select`, `ui_submit`.

- `label: false` renders an sr-only label (still accessible).
- `ui_select(:kind, choices, { label: "Kind", hint: "Pick one" }, { class: "..." })` takes `label:` and `hint:` in
  the options hash (third argument); HTML options come fourth.
- `hint:` adds helper text; errors are rendered under the field and linked through `aria-describedby`.
- When the same form appears twice on a page, use `form_with namespace: "a"` so ids stay unique.

## Theme

Colors are CSS variables (`--background`, `--primary`, `--success`, ...) mapped to Tailwind utilities
(`bg-background`, `text-muted-foreground`, ...). Override any variable after the import to rebrand.
The theme toggle cycles light, dark, then system.

## Icons and fonts

```ruby
GeekofiaUi.configure do |c|
  c.icon_provider = :lucide            # :iconify, :font_awesome, :material_symbols, or an object
  c.font_provider = :bunny             # :system (default), :google, :self_hosted, or an object
  c.font_sans = "Inter"
  c.font_mono = "JetBrains Mono"
end
```

Semantic icon names are Symbols (`ui_icon(:copy)`): `copy check sun moon monitor info alert_triangle
alert_circle check_circle x plus server terminal refresh pencil trash external_link help arrow_left
log_out hard_drive key play plug more`. Strings are raw provider names and are passed through as-is.
With iconify, `icon_set` qualifies any name that is not already `set:name`. `icon_aliases` override
semantic names (`{ copy: "clipboard" }`).

Config notes:

- Assign `icon_aliases` and `font_weights` new values rather than mutating them; the defaults are frozen.
- Font family names may only contain letters, digits, space, `_`, `.`, `'` and `-`. Anything else raises when rendered.

Custom providers:

- Icon providers implement `render(name, size:, css_class:, attrs:)` and `head_tags(nonce: nil)`.
  The `nonce` keyword is optional; providers that do not accept it are called without one.
- Font providers implement `head_tags(nonce: nil)` and `stacks`, returning `{ sans:, mono: }`.

## Development

```sh
bin/rails test
bin/sync-lucide /path/to/lucide-static/package   # refresh bundled icons
```

Lucide icons are ISC-licensed (see `lib/geekofia_ui/icons/lucide/LICENSE`).
