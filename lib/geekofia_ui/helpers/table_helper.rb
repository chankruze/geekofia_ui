module GeekofiaUi
  module Helpers
    module TableHelper
      class RowBuilder
        CELL = {
          th: "h-10 whitespace-nowrap px-3 first:pl-6 last:pr-6 text-left align-middle text-xs font-medium uppercase tracking-wide text-muted-foreground",
          td: "px-3 py-3 align-middle first:pl-6 last:pr-6"
        }.freeze

        def initialize(view, tag)
          @view = view
          @tag = tag
        end

        def cell(content = nil, **attrs, &block)
          attrs[:scope] ||= "col" if @tag == :th
          @view.content_tag(@tag, block ? @view.capture(&block) : content,
                            class: GeekofiaUi::ClassMerge.call(CELL.fetch(@tag), attrs.delete(:class)), **attrs)
        end

        def header_cell(content = nil, **attrs, &block)
          @view.content_tag(:th, block ? @view.capture(&block) : content, scope: "row", **attrs,
                            class: GeekofiaUi::ClassMerge.call(CELL.fetch(:td), "font-medium", attrs.delete(:class)))
        end
      end

      class TableBuilder
        def initialize(view)
          @view = view
        end

        def head(&block)
          @view.content_tag(:thead, @view.content_tag(:tr, @view.capture(RowBuilder.new(@view, :th), &block),
                                                      class: "border-b border-border"))
        end

        def body(&block) = @view.content_tag(:tbody, @view.capture(&block), class: "[&_tr:last-child]:border-0")

        def row(**attrs, &block)
          @view.content_tag(:tr, @view.capture(RowBuilder.new(@view, :td), &block),
                            class: GeekofiaUi::ClassMerge.call("border-b border-border transition-colors hover:bg-muted/50",
                                                               attrs.delete(:class)), **attrs)
        end
      end

      def ui_table(**attrs, &block)
        render(partial: "geekofia_ui/components/table", formats: [ :html ],
               locals: { body: capture(TableBuilder.new(self), &block),
                         css: ui_classes("w-full caption-bottom text-sm", attrs.delete(:class)), attrs: })
      end
    end
  end
end
