module Chaltron
  module Sortable
    extend ActiveSupport::Concern

    included do
      helper_method :sort_column, :sort_direction, :sort_columns
    end

    module ClassMethods
      def sort_column
        defined?(@default_sort_column) ? @default_sort_column : "created_at"
      end

      def sort_direction
        defined?(@default_sort_direction) ? @default_sort_direction : "desc"
      end

      def default_sort_direction(dir)
        @default_sort_direction = dir.to_s
      end

      def default_sort_column(col)
        @default_sort_column = col.to_s
      end

      def permitted_sort_columns(col)
        @permitted_sort_columns = col
      end
    end

    def sort_direction
      return @sort_direction if defined?(@sort_direction)

      @sort_direction = validate_sort_direction
    end

    def sort_column
      return @sort_column if defined?(@sort_column)

      @sort_column = validate_sort_column
    end

    def sort_columns
      self.class.instance_variable_get(:@permitted_sort_columns) || [self.class.sort_column]
    end

    private

    def validate_sort_direction
      %w[asc desc].include?(params[:sort_direction]) ? params[:sort_direction] : self.class.sort_direction
    end

    def validate_sort_column
      permitted = self.class.instance_variable_get(:@permitted_sort_columns)
      if permitted.present?
        permitted.include?(params[:sort_column]) ? params[:sort_column] : self.class.sort_column
      else
        params[:sort_column].nil? ? self.class.sort_column : params[:sort_column]
      end
    end
  end
end
