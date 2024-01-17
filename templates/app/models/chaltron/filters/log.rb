module Chaltron
  module Filters
    class Log < Base
      module Scopes
        extend Scopeable
        def by_categories(cat)
          where(category: cat) if cat.present?
        end

        def by_severities(sev)
          where(severity: sev) if sev.present?
        end

        scope %i[by_categories by_severities]
      end
      attribute :categories, array: true, default: -> { [] }
      attribute :severities, array: true, default: -> { [] }

      def apply(scope)
        categories&.compact_blank!
        severities&.compact_blank!

        scope
          .extending(Scopes)
          .by_categories(categories)
          .by_severities(severities)
      end
    end
  end
end
