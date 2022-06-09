module Chaltron
  module SearchSortAndPaginate
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend
      helper_method :sort_column, :sort_direction, :per_page, :filter_search
    end

    module ClassMethods
      def sort_column
        defined?(@default_sort_column) ? @default_sort_column : 'created_at'
      end

      def sort_direction
        defined?(@default_sort_direction) ? @default_sort_direction : 'desc'
      end

      def per_page
        defined?(@default_per_page) ? @default_per_page : Pagy::DEFAULT[:items]
      end

      def default_sort_direction(dir)
        @default_sort_direction = dir.to_s
      end

      def default_sort_column(col)
        @default_sort_column = col.to_s
      end

      def default_per_page(count)
        @default_per_page = count
      end

      def permitted_sort_columns(col)
        @permitted_sort_columns = col
      end
    end

    private

    %w[sort_direction sort_column per_page filter_search].each do |name|
      define_method(name) do
        memoize(name)
      end

      define_method("perform_#{name}") do
        send("validate_#{name}")
      end
    end

    def validate_sort_direction
      %w[asc desc].include?(params[:sort_direction]) ? params[:sort_direction] : self.class.sort_direction
    end

    def validate_sort_column
      permitted = self.class.instance_variable_get(:@permitted_sort_columns)
      if permitted.present?
        permitted.include?(params[:sort_column]) ? params[:sort_column] : self.class.sort_column
      else
        params[:sort].nil? ? self.class.sort_column : params[:sort_column]
      end
    end

    def validate_per_page
      ret = params[:per_page]&.to_i
      ret&.positive? ? ret : self.class.per_page
    end

    def validate_filter_search
      params[:search]
    end

    # simple memoization method
    def memoize(name)
      var_name = "@#{name}".to_sym
      return instance_variable_get(var_name) if instance_variable_get(var_name).present?

      instance_variable_set(var_name, send("perform_#{name}"))
    end
  end
end
