module GeekofiaUi
  module Helpers
    module LayoutHelper
      class CardBuilder
        def initialize(view)
          @view = view
        end

        def header(title: nil, description: nil, title_tag: :h2, &actions)
          @view.render(partial: "geekofia_ui/components/card_header", formats: [ :html ],
                       locals: { title:, description:, title_tag:, actions: actions && @view.capture(&actions) })
        end

        def content(**attrs, &block)
          raise ArgumentError, "ui_card content needs a block" unless block

          @view.content_tag(:div, @view.capture(&block),
                            class: GeekofiaUi::ClassMerge.call("p-6 not-first:pt-0", attrs.delete(:class)), **attrs)
        end

        def footer(**attrs, &block)
          raise ArgumentError, "ui_card footer needs a block" unless block

          @view.content_tag(:div, @view.capture(&block),
                            class: GeekofiaUi::ClassMerge.call("flex items-center gap-2 border-t border-border px-6 py-4",
                                                               attrs.delete(:class)), **attrs)
        end
      end

      def ui_card(**attrs, &block)
        css = ui_classes("rounded-xl border border-border bg-card text-card-foreground shadow-sm", attrs.delete(:class))
        content_tag(:div, capture(CardBuilder.new(self), &block), class: css, **attrs)
      end

      def ui_page_header(title:, description: nil, badge: nil, &actions)
        render(partial: "geekofia_ui/components/page_header", formats: [ :html ],
               locals: { title:, description:, badge:, actions: actions && capture(&actions) })
      end

      def ui_empty_state(title:, description: nil, icon: nil, title_tag: :h3, &actions)
        render(partial: "geekofia_ui/components/empty_state", formats: [ :html ],
               locals: { title:, description:, icon:, title_tag:, actions: actions && capture(&actions) })
      end
    end
  end
end
