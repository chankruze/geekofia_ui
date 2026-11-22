module GeekofiaUi
  module Helpers
    module Support
      private

      def ui_classes(*lists) = GeekofiaUi::ClassMerge.call(*lists)

      def ui_option!(name, value, allowed)
        sym = value.to_s.to_sym
        return sym if allowed.include?(sym)
        raise ArgumentError, "#{name}: #{value.inspect} is not one of #{allowed.map(&:inspect).join(", ")}"
      end
    end
  end
end
