module Chaltron
  module SortAndPaginate
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend
      helper_method :sort_column, :sort_direction, :sort_per_page
    end

    module ClassMethods
      def sort_column
        defined?(@sort_column) ? @sort_column : 'created_at'
      end

      def sort_direction
        defined?(@sort_direction) ? @sort_direction : 'desc'
      end

      def per_page
        defined?(@per_page) ? @per_page : Pagy::DEFAULT[:items]
      end

      def default_sort_direction(dir)
        @sort_direction = dir.to_s
      end

      def default_sort_column(col)
        @sort_column = col.to_s
      end

      def default_per_page(count)
        @per_page = count
      end

      def permitted_sort_columns(col)
        @permitted_sort_columns = col
      end
    end

    private

    def sort_column
      permitted = self.class.instance_variable_get(:@permitted_sort_columns)
      if permitted.present?
        permitted.include?(params[:sort]) ? params[:sort] : self.class.sort_column
      else
        params[:sort].nil? ? self.class.sort_column : params[:sort]
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : self.class.sort_direction
    end

    def sort_per_page
      ret = params[:per_page]&.to_i
      ret&.positive? ? ret : self.class.per_page
    end
  end
end
