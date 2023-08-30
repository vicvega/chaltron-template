module Chaltron
  module Paginatable
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend
      helper_method :per_page, :page
    end

    module ClassMethods
      def per_page
        defined?(@default_per_page) ? @default_per_page : Pagy::DEFAULT[:items]
      end

      def default_per_page(count)
        @default_per_page = count
      end
    end

    def per_page
      return @per_page if defined?(@per_page)

      @per_page = validate_per_page
    end

    def page
      return @page if defined?(@page)

      @page = validate_page
    end

    private

    def validate_per_page
      ret = params[:per_page]&.to_i
      ret&.positive? ? ret : self.class.per_page
    end

    def validate_page
      ret = params[:page]&.to_i
      ret&.positive? ? ret : 1
    end
  end
end
