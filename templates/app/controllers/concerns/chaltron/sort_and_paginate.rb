module Chaltron
  module SortAndPaginate
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend
      helper_method :per_page, :page, :sort_column, :sort_direction, :sort_columns
    end
    class_methods do
      def sort_and_paginate(*columns)
        options = columns.extract_options!
        callback_options = options.extract!(:only, :except, :if, :unless)
        callback = Callback.new(columns, options[:defaults])
        before_action callback, callback_options
      end
    end

    attr_accessor :sort_and_paginate_defaults, :sort_columns

    delegate :per_page, :page, :sort_column, :sort_direction, to: :status

    private

    def status
      @sort_and_pagination_status ||= Status.create!(status_params)
    end

    def status_params
      params
        .slice!(:per_page, :page, :sort_column, :sort_direction)
        .permit!
        .with_defaults(sort_and_paginate_defaults)
        .merge(sort_columns: sort_columns)
    end
  end
end
