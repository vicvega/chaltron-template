module Chaltron
  module SessionRateLimiting
    extend ActiveSupport::Concern
    module ClassMethods
      def session_rate_limit(**)
        rate_limit(
          to: 10, within: 3.minutes,
          with: -> { redirect_to new_local_session_path, alert: I18n.t("chaltron.rate_limited") },
          **
        )
      end
    end
  end
end
