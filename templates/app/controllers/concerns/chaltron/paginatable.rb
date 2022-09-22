module Chaltron
  module Paginatable
    extend ActiveSupport::Concern
    include Memoizable

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
      memoize('per_page') { perform_per_page }
    end

    def page
      memoize('page') { perform_page }
    end

    private

    %w[per_page page].each do |name|
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
