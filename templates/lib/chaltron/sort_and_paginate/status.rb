module Chaltron
  module SortAndPaginate
    class Status
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations

      SORT_DIRECTIONS = %w[asc desc]
      DEFAULTS = {
        page: 1,
        per_page: Pagy::DEFAULT[:items],
        sort_column: "created_at",
        sort_direction: SORT_DIRECTIONS.last
      }

      attribute :per_page, :integer, default: DEFAULTS[:per_page]
      attribute :page, :integer, default: DEFAULTS[:page]
      attribute :sort_column, :string, default: DEFAULTS[:sort_column]
      attribute :sort_direction, :string, default: DEFAULTS[:sort_direction]
      attribute :sort_columns, array: true

      validates_inclusion_of :sort_direction, in: SORT_DIRECTIONS
      validates_numericality_of :page, :per_page, greater_than: 0, only_integer: true
      validate :validate_sort_column

      def validate_sort_column
        errors.add(:sort_column, :inclusion) unless sort_columns.include?(sort_column)
      end

      def sanitize_all_attributes
        assign_attributes(self.class::DEFAULTS)
      end

      def self.create!(args)
        object = new(args)
        object.sanitize_all_attributes unless object.valid?
        raise ArgumentError.new(object.errors.full_messages.to_sentence) unless object.valid?
        object
      end
    end
  end
end
