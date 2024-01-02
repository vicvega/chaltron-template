module Chaltron
  module Searching
    extend ActiveSupport::Concern

    included do
      helper_method :search
    end

    def search
      @search ||= search_params.strip
    end

    def search_params
      params.fetch(:search, "")
    end
  end
end
