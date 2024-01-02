module Chaltron
  module Sorting
    class Status
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations
      extend Chaltron::CreateValidOrResetParams

      DIRECTIONS = %w[asc desc]

      attribute :column, :string, default: "created_at"
      attribute :direction, :string, default: DIRECTIONS.last
      attribute :columns, array: true, default: []

      validates_inclusion_of :direction, in: DIRECTIONS
      validate :validate_column

      def validate_column
        errors.add(:column, :inclusion) unless columns.include?(column)
      end
    end
  end
end
