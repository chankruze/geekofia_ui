require "action_view"

module GeekofiaUi
  # form_with(model:, builder: GeekofiaUi::FormBuilder) { |f| f.ui_text_field :name, hint: "…" }
  class FormBuilder < ActionView::Helpers::FormBuilder
    INPUT = "flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs transition-colors " \
            "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
            "disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/30"
    TEXTAREA = INPUT.sub("flex h-9", "flex min-h-20").sub("py-1", "py-2")
    LABEL = "text-sm font-medium leading-none"

    %i[text_field email_field password_field number_field].each do |kind|
      define_method(:"ui_#{kind}") do |method, label: nil, hint: nil, **options|
        ui_field(method, label:, hint:) { |aria| public_send(kind, method, **control_options(options, INPUT, aria)) }
      end
    end

    def ui_text_area(method, label: nil, hint: nil, **options)
      ui_field(method, label:, hint:) { |aria| text_area(method, **control_options(options, TEXTAREA, aria)) }
    end

    def ui_select(method, choices, options = {}, html_options = {})
      options = options.dup
      label = options.delete(:label)
      hint = options.delete(:hint)
      ui_field(method, label:, hint:) { |aria| select(method, choices, options, control_options(html_options, INPUT, aria)) }
    end

    def ui_submit(value = nil, variant: :default, **options)
      @template.ui_button(value || submit_default_value, type: "submit", variant:, **options)
    end

    private

    def ui_field(method, label:, hint:)
      base_id = field_id(method)
      hint_id = "#{base_id}_hint"
      error_id = "#{base_id}_error"
      messages = object.respond_to?(:errors) ? object.errors.full_messages_for(method) : []
      described_by = [ (hint_id if hint), (error_id if messages.any?) ].compact.join(" ").presence
      aria = { invalid: (true if messages.any?), describedby: described_by }.compact

      @template.content_tag(:div, class: "space-y-2", data: { ui_field: method }) do
        @template.safe_join([
          label(method, label, class: LABEL),
          yield(aria),
          (@template.content_tag(:p, hint, id: hint_id, class: "text-xs text-muted-foreground") if hint),
          (@template.content_tag(:p, messages.to_sentence, id: error_id, class: "text-xs font-medium text-destructive") if messages.any?)
        ].compact)
      end
    end

    def control_options(options, base, aria)
      options = options.dup
      options[:class] = GeekofiaUi::ClassMerge.call(base, options[:class])
      options[:aria] = (options[:aria] || {}).merge(aria)
      options
    end
  end
end
