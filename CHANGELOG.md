# Changelog

## 0.3.0

- New `ui_tabs` (`t.tab`): link-based tab bar with `aria-current="page"`, exact or prefix matching, optional badge and status dot. No JavaScript.

## 0.2.0

- New `ui_dropdown_menu` (`m.item`, `m.separator`): accessible menu button with keyboard navigation, `align:`, item `method:`, `params:`, `icon:` and `variant: :destructive`. Needs JavaScript.
- New `ui_confirm_dialog` and `ui-confirm` Stimulus controller: replaces Turbo's `window.confirm` for `data-turbo-confirm` (Turbo 8 / turbo-rails 2) with a styled dialog; supports `data-confirm-title`, `data-confirm-button` and `data-confirm-variant`.
- `confirm:` option on `ui_button` and dropdown items (String or `{ message:, title:, button:, variant: }`).
- New `:more` semantic icon (Lucide `ellipsis`).
- The install generator adds `ui_confirm_dialog` before `</body>` in the application layout.

## 0.1.2

- Re-release of the 0.1.1 changes. The `v0.1.1` git tag points at an incomplete commit (no version bump, changelog or README fixes); use `v0.1.2` instead.

## 0.1.1

- Theme toggle merges caller `class:`, `data:` and `aria:` instead of overriding them.
- Form builder labels use Rails' own `for`, so `form_with namespace:` keeps label, input, hint and error ids in sync.
- `ui_page_header`, `ui_empty_state`, `ui_card` header and `ui_steps` step accept `class:` and HTML attributes; `ui_page_header` takes `title_tag:`.
- `ui_icon` coerces `size` with `Integer()`.
- `border-dashed` and friends no longer collide with border colors in class merging.
- Tighter dependency constraints; README fixes; packaging cleanup.

## 0.1.0

- Initial release: `ui_*` helpers, form builder, Stimulus clipboard and theme controllers, Tailwind v4 theme, pluggable icon and font providers, install generator.
