module Chaltron
  module Filterable
    extend ActiveSupport::Concern

    class_methods do
      def filtrate(filter)
        filter.apply(all)
      end
    end
  end
end
