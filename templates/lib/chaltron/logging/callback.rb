module Chaltron
  module Logging
    class Callback
      def initialize(category)
        @category = category
      end

      def before(controller)
        controller.default_log_category = category
      end

      private

      attr_reader :category
    end
  end
end
