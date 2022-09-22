module Chaltron
  module Sortable
    extend ActiveSupport::Concern
    include Memoizable

    included do
      helper_method :sort_column, :sort_direction
    end

    module ClassMethods
      def sort_column
        defined?(@default_sort_column) ? @default_sort_column : 'created_at'
      end

      def sort_direction
        defined?(@default_sort_direction) ? @default_sort_direction : 'desc'
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

      def store_prefix(prefix)
        @store_prefix = prefix
      end
    end

    def sort_direction
      memoize('sort_direction') { perform_sort_direction }
    end

    def sort_column
      memoize('sort_column')  { perform_sort_column }
    end

    private

    %w[sort_column sort_direction].each do |name|
      define_method("perform_#{name}") do
        default = self.class.respond_to?(name) ? self.class.send(name) : nil
        return default if params[name.to_sym].nil?

        send("validate_#{name}")
      end
    end

    def session_key(name)
      prefix = self.class.controller_name
      "#{prefix}_#{name}".to_sym
    end

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