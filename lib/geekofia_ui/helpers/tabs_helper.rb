module GeekofiaUi
  module Helpers
    module TabsHelper
      TAB_BASE = "inline-flex shrink-0 items-center gap-2 whitespace-nowrap rounded-t-sm border-b-2 px-1 pb-2.5 pt-1 " \
                 "text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 " \
                 "focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background"
      TAB_STATES = {
        active: "border-foreground text-foreground",
        inactive: "border-transparent text-muted-foreground hover:border-border hover:text-foreground"
      }.freeze
      TAB_DOTS = { success: "bg-success", warning: "bg-warning", destructive: "bg-destructive" }.freeze
      TAB_MATCHES = %i[exact prefix].freeze

      class TabsBuilder
        def initialize(view)
          @view = view
        end

        def tab(label, href:, **options)
          @view.send(:ui_tab, label, href:, **options)
        end
      end

      def ui_tabs(label:, **attrs, &block)
        tabs = capture(TabsBuilder.new(self), &block)
        content_tag(:nav, class: ui_classes("border-b border-border", attrs.delete(:class)), aria: { label: }, **attrs) do
          tag.div(tabs, class: "-mb-px flex gap-6 overflow-x-auto")
        end
      end

      private

      def ui_tab(label, href:, active: nil, match: :exact, badge: nil, badge_variant: :secondary, dot: nil,
                 dot_label: "attention", **attrs)
        ui_option!(:match, match, TAB_MATCHES)
        active = ui_tab_active?(href, match) if active.nil?
        dot_tag = if dot
          safe_join([
            tag.span(class: ui_classes("size-2 rounded-full", TAB_DOTS.fetch(ui_option!(:dot, dot, TAB_DOTS.keys))),
                     aria: { hidden: true }),
            tag.span(dot_label, class: "sr-only")
          ])
        end
        badge_tag = ui_badge(badge.to_s, variant: badge_variant) unless badge.nil? || badge.to_s.strip.empty? || badge.to_s == "0"
        link_to(href, class: ui_classes(TAB_BASE, TAB_STATES.fetch(active ? :active : :inactive), attrs.delete(:class)),
                      aria: { current: ("page" if active) }, **attrs) do
          safe_join([ tag.span(label), dot_tag, badge_tag ].compact)
        end
      end

      def ui_tab_active?(href, match)
        return current_page?(href) if match == :exact

        target = URI.parse(href.to_s).path.to_s.chomp("/")
        path = request.path.to_s.chomp("/")
        path == target || path.start_with?("#{target}/")
      end
    end
  end
end
