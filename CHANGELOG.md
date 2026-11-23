# Changelog

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
