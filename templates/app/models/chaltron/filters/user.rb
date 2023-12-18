module Chaltron
  module Filters
    class User < Base
      module Scopes
        extend Scopeable

        scope :by_providers, ->(prov) { where(provider: prov) if prov.present? }
        scope :never_logged_in, ->(never) { where(sign_in_count: 0) if never }
      end
      attribute :providers, array: true, default: -> { [] }
      attribute :never_logged_in, :boolean, default: -> { false }

      def apply(scope)
        providers&.compact_blank!

        scope
          .extending(Scopes)
          .by_providers(providers.map { |k| (k == "local") ? nil : k })
          .never_logged_in(never_logged_in)
      end
    end
  end
end
