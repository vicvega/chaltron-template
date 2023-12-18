module Chaltron
  module Filterable
    extend ActiveSupport::Concern

    included do
      scope :filter_by, ->(filter) { filter.apply(self) }
    end
  end
end
