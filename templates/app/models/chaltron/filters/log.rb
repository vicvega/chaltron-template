module Chaltron
  module Filters
    class Log < Base
      module Scopes
        extend Scopeable
        scope :by_search, ->(search) { where("message LIKE :query", {query: "%#{search.strip}%"}) if search.present? }
        scope :by_categories, ->(cat) { where(category: cat) if cat.present? }
        scope :by_severities, ->(sev) { where(severity: sev) if sev.present? }
      end
      attribute :search
      attribute :categories, array: true, default: -> { [] }
      attribute :severities, array: true, default: -> { [] }

      def apply(scope)
        categories&.compact_blank!
        severities&.compact_blank!

        scope
          .extending(Scopes)
          .by_search(search)
          .by_categories(categories)
          .by_severities(severities)
      end
    end
  end
end
