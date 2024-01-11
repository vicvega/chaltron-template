module Chaltron
  module Sorting
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend
      helper_method :sort_column, :sort_direction, :sort_columns
    end
    class_methods do
      def sorting(*columns)
        options = columns.extract_options!
        callback_options = options.extract!(:only, :except, :if, :unless)
        callback = Callback.new(columns, options[:defaults])
        before_action callback, callback_options
      end
    end

    attr_accessor :sorting_defaults, :sort_columns

    delegate :column, :direction, to: :sort_status, prefix: "sort"

    private

    def sort_status
      @sort_status ||= Status.create(sort_status_params) # standard:disable Rails/SaveBang
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
