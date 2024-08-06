module Chaltron
  module Filters
    class Base
      include ActiveModel::Model
      include ActiveModel::Attributes

      extend ActiveModel::Callbacks
      define_model_callbacks :initialize, only: [:after]

      after_initialize :compact_arrays

      def initialize(attributes = {})
        run_callbacks :initialize do
          super
        end
      end

      private

      def compact_arrays
        attributes.each do |k, v|
          send(k).compact_blank! if v.is_a? Array
        end
      end
    end
  end
end
