module Chaltron
  module Sorting
    extend ActiveSupport::Concern

    included do
      helper_method :sort_column, :sort_direction, :sort_columns
    end

    attr_accessor :sorting_defaults, :sort_columns
    delegate :column, :direction, to: :sort_status, prefix: "sort"

    def sorts(*columns, defaults: {})
      self.sorting_defaults = defaults
      self.sort_columns = columns
    end

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

    private

    def sort_status
      @sort_status ||= Status.create_valid(sort_status_params)
    end

    def sort_status_params
      parameters = %i[sort_column sort_direction]
      params
        .extract!(*parameters)
        .permit(*parameters)
        .transform_keys { |x| x.gsub("sort_", "") }
        .with_defaults(sorting_defaults)
        .tap { |x| x[:columns] = sort_columns if sort_columns.present? }
    end
  end
end
