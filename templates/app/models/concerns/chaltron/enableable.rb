module Chaltron
  module Enableable
    extend ActiveSupport::Concern

    included do
      scope :enabled,  -> { where(enabled: true) }
      scope :disabled, -> { where(enabled: false) }
    end

    def enabled?
      self.enabled
    end

    def disabled?
      !self.enabled
    end

    def enable!
      update!(enabled: true)
    end

    def disable!
      update!(enabled: false)
    end

  end
end
