module Chaltron
  module Enableable
    extend ActiveSupport::Concern

    included do
      scope :enabled, -> { where(enabled: true) }
      scope :disabled, -> { where(enabled: false) }
    end

    def enabled?
      enabled
    end

    def disabled?
      !enabled
    end

    def enable!
      update!(enabled: true)
    end

    def disable!
      update!(enabled: false)
    end

    # override devise method to check if user account is active
    def active_for_authentication?
      super && enabled?
    end

    def inactive_message
      enabled? ? super : I18n.t("chaltron.users.inactive_message")
    end
  end
end
