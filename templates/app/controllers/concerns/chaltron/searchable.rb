module Chaltron
  module Searchable
    extend ActiveSupport::Concern

    included do
      helper_method :search
    end

    def search
      @search ||= params[:search]
    end
  end
end
