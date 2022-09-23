module Chaltron
  module Filterable
    extend ActiveSupport::Concern
    include Memoizable

    included do
      helper_method :filter_search
    end

    def filter_search
      memoize('filter_search') { perform_filter_search }
    end

    private

    def perform_filter_search
      params[:search]
    end
  end
end
