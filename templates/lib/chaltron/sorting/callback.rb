module Chaltron
  module Sorting
    class Callback
      def initialize(columns, defaults)
        raise ArgumentError.new("Sorting columns must be specified") if columns.empty?

        @columns = columns
        @defaults = defaults
      end

      def before(controller)
        controller.sorting_defaults = defaults
        controller.sort_columns = columns
      end

      private

      attr_reader :columns, :defaults
    end
  end
end
