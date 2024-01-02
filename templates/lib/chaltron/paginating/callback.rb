module Chaltron
  module Paginating
    class Callback
      def initialize(defaults = {})
        @defaults = defaults
      end

      def before(controller)
        controller.paginating_defaults = defaults
      end

      private

      attr_reader :defaults
    end
  end
end
