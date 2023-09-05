module Chaltron
  module Filters
    class User < Base
      attribute :providers, array: true, default: -> { [] }
      attribute :never_logged_in, :boolean, default: -> { false }

      def apply(ret)
        # otherwise a filter with no providers should filter everything
        providers&.compact_blank!

        ret = ret.where(provider: providers.map { |k| (k == "local") ? nil : k }) if providers.present?
        ret = ret.where(sign_in_count: 0) if never_logged_in
        ret
      end
    end
  end
end
