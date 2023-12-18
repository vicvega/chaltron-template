module Chaltron
  module SortAndPaginate
    class Callback
      def initialize(columns, defaults)
        raise ArgumentError.new("Sortable columns must be specified") if columns.empty?

        @columns = columns
        @defaults = defaults
      end

      def before(controller)
        controller.sort_and_paginate_defaults = defaults
        controller.sort_columns = columns
      end

      private

      attr_reader :columns, :defaults
    end
  end
end
