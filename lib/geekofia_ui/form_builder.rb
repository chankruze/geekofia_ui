require "action_view"

module GeekofiaUi
  # form_with(model:, builder: GeekofiaUi::FormBuilder) { |f| f.ui_text_field :name, hint: "…" }
  class FormBuilder < ActionView::Helpers::FormBuilder
    INPUT = "flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-base md:text-sm shadow-xs transition-colors " \
            "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
            "disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/30 " \
            "dark:bg-input/30 dark:aria-invalid:ring-destructive/40"
    TEXTAREA = INPUT.sub("flex h-9", "flex min-h-20").sub("py-1", "py-2")
    SELECT = GeekofiaUi::ClassMerge.call(INPUT.sub(/placeholder:\S+ ?/, ""), "pr-8 [&>option]:bg-popover [&>option]:text-popover-foreground")
    LABEL = "text-sm font-medium leading-none"

    %i[text_field email_field password_field number_field].each do |kind|
      define_method(:"ui_#{kind}") do |method, label: nil, hint: nil, **options|
        ui_field(method, options, label:, hint:) { |aria| public_send(kind, method, **control_options(options, INPUT, aria)) }
      end
    end

    def ui_text_area(method, label: nil, hint: nil, **options)
      ui_field(method, options, label:, hint:) { |aria| text_area(method, **control_options(options, TEXTAREA, aria)) }
    end

    def ui_select(method, choices, options = {}, html_options = {})
      options = options.dup
      label = options.delete(:label)
      hint = options.delete(:hint)
      ui_field(method, html_options, label:, hint:) { |aria| select(method, choices, options, control_options(html_options, SELECT, aria)) }
    end

    def ui_submit(value = nil, variant: :default, **options)
      @template.ui_button(value || submit_default_value, type: "submit", variant:, **options)
    end

    private

    def ui_field(method, options, label:, hint:)
      base_id = options[:id].presence || field_id(method)
      hint_id = "#{base_id}_hint"
      error_id = "#{base_id}_error"
      messages = object.respond_to?(:errors) ? object.errors.full_messages_for(method) : []
      described_by = [ (hint_id if hint.present?), (error_id if messages.any?) ].compact.join(" ").presence
      aria = { invalid: (true if messages.any?), describedby: [ options.dig(:aria, :describedby), described_by ].compact.join(" ").presence }.compact

      @template.content_tag(:div, class: "space-y-2", data: { ui_field: method }) do
        @template.safe_join([
          ui_label(method, label, options),
          yield(aria),
          (@template.content_tag(:p, hint, id: hint_id, class: "text-xs text-muted-foreground") if hint.present?),
          (@template.content_tag(:p, messages.to_sentence, id: error_id, class: "text-xs font-medium text-destructive") if messages.any?)
        ].compact)
      end
    end

    # Only an explicit id: overrides the label's for; otherwise Rails derives it
    # (including form_with namespace:) exactly as it does for the input.
    def ui_label(method, label, options)
      css = label == false ? "sr-only" : LABEL
      text = label == false ? nil : label
      label_options = { class: css }
      label_options[:for] = options[:id] if options[:id].present?
      label(method, text, **label_options)
    end

    def control_options(options, base, aria)
      options = options.dup
      options[:class] = GeekofiaUi::ClassMerge.call(base, options[:class])
      options[:aria] = (options[:aria] || {}).merge(aria)
      options
    end
  end
end
