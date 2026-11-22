module GeekofiaUi
  module Helpers
    module CopyHelper
      def ui_copy_button(text = nil, source: nil, label: "Copy", size: :sm, variant: :outline, **attrs)
        raise ArgumentError, "ui_copy_button needs text or source:" if text.nil? && source.nil?

        data = { controller: "ui-clipboard", action: "ui-clipboard#copy",
                 "ui-clipboard-text-value": text, "ui-clipboard-source-value": source }.compact
        render(partial: "geekofia_ui/components/copy_button", formats: [ :html ],
               locals: { label:, size:, variant:, data: data.merge(attrs.delete(:data) || {}), attrs: })
      end

      def ui_code_block(text, language: nil, copy: true, wrap: false, **attrs)
        render(partial: "geekofia_ui/components/code_block", formats: [ :html ],
               locals: { text:, language:, copy:, wrap:,
                         css: ui_classes("relative rounded-lg border border-border bg-muted/50", attrs.delete(:class)),
                         attrs: })
      end
    end
  end
end
