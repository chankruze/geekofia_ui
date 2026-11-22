module GeekofiaUi
  module Helpers
    module StepsHelper
      class StepsBuilder
        def initialize(view)
          @view = view
          @number = 0
        end

        def step(title:, done: false, &block)
          @number += 1
          @view.render(partial: "geekofia_ui/components/step", formats: [ :html ],
                       locals: { number: @number, title:, done:, body: block && @view.capture(&block) })
        end
      end

      def ui_steps(**attrs, &block)
        content_tag(:ol, capture(StepsBuilder.new(self), &block), class: ui_classes("space-y-6", attrs.delete(:class)), role: "list", **attrs)
      end
    end
  end
end
