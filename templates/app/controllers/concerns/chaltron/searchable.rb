module Chaltron
  module Searchable
    extend ActiveSupport::Concern

    included do
      helper_method :search
    end

    module ClassMethods
      def default_policy
        {strip: true}
      end

      def policy
        policy = defined?(@policy) ? @policy : {}
        default_policy.merge(policy)
      end

      def searchable(policy)
        @policy = policy
      end
    end

    def search
      return @search if defined?(@search)

      @search = search_by_policy
    end

    def search_by_policy
      self.class.policy[:strip] ? params[:search]&.strip : params[:search]
    end
  end
end
