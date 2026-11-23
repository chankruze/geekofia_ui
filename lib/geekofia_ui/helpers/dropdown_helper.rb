module GeekofiaUi
  module Helpers
    module DropdownHelper
      DROPDOWN_ITEM_BASE = "flex w-full cursor-pointer select-none items-center gap-2 rounded-sm px-2 py-1.5 text-left text-sm " \
                           "outline-none transition-colors hover:bg-accent hover:text-accent-foreground " \
                           "focus-visible:bg-accent focus-visible:text-accent-foreground"
      DROPDOWN_ITEM_VARIANTS = {
        default: "",
        destructive: "text-destructive hover:bg-destructive/10 hover:text-destructive focus-visible:bg-destructive/10 focus-visible:text-destructive"
      }.freeze
      DROPDOWN_ALIGNMENTS = { end: "right-0", start: "left-0" }.freeze

      class MenuBuilder
        def initialize(view)
          @view = view
        end

        def item(label, href:, **options)
          @view.send(:ui_dropdown_item, label, href:, **options)
        end

        def separator = @view.tag.div(role: "separator", class: "-mx-1 my-1 h-px bg-border")
      end

      def ui_dropdown_menu(label: "More actions", icon: :more, align: :end, **attrs, &block)
        align_class = DROPDOWN_ALIGNMENTS.fetch(ui_option!(:align, align, DROPDOWN_ALIGNMENTS.keys))
        caller_data = attrs.delete(:data) || {}
        data = caller_data.merge(
          controller: [ "ui-dropdown", caller_data[:controller] ].compact.join(" "),
          action: [ "turbo:before-cache@document->ui-dropdown#close", caller_data[:action] ].compact.join(" ")
        )
        menu_id = "ui-dropdown-#{SecureRandom.hex(4)}"
        render(partial: "geekofia_ui/components/dropdown_menu", formats: [ :html ],
               locals: { label:, icon:, align_class:, menu_id:, trigger_id: "#{menu_id}-trigger", items: capture(MenuBuilder.new(self), &block),
                         css: ui_classes("relative inline-block text-left", attrs.delete(:class)),
                         attrs: attrs.merge(data:) })
      end

      private

      def ui_dropdown_item(label, href:, method: nil, icon: nil, variant: :default, confirm: nil, params: nil, **attrs)
        classes = ui_classes(DROPDOWN_ITEM_BASE,
                             DROPDOWN_ITEM_VARIANTS.fetch(ui_option!(:variant, variant, DROPDOWN_ITEM_VARIANTS.keys)),
                             attrs.delete(:class))
        body = safe_join([ (ui_icon(icon) if icon), tag.span(label) ].compact)
        caller_data = attrs.delete(:data) || {}
        data = caller_data.merge(action: [ "ui-dropdown#select", caller_data[:action] ].compact.join(" "))
        item_attrs = { role: "menuitem", tabindex: "-1", class: classes, data: }
        verb = method&.to_s&.downcase
        if verb.nil? || verb == "get"
          href = "#{href}#{href.include?("?") ? "&" : "?"}#{params.to_query}" if params.present?
          link_to(body, href, **item_attrs, **attrs)
        else
          button_to(href, method: verb.to_sym, params: params || {},
                    form: { class: "contents", data: ui_confirm_data(confirm) }, **item_attrs, **attrs) { body }
        end
      end
    end
  end
end
