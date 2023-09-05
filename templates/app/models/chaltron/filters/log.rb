module Chaltron
  module Filters
    class Log < Base
      attribute :categories, array: true, default: -> { [] }
      attribute :severities, array: true, default: -> { [] }

      def apply(ret)
        # otherwise a filter with no categories/severities should filter everything
        categories&.compact_blank!
        severities&.compact_blank!
        ret = ret.where(category: categories) if categories.present?
        ret = ret.where(severity: severities) if severities.present?
        ret
      end
    end
  end
end
