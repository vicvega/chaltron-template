# require 'syslog'
module Chaltron
  class Log < ApplicationRecord
    enum :severity, %i[emerg alert crit err warning notice info debug]

    validates :severity, :category, :message, presence: true

    before_validation :truncate_message

    # after_create :to_syslog

    private

    def truncate_message
      self.message = message&.truncate(1000)
    end

    # def to_syslog
    #   Syslog.open(Rails.application.class.parent.to_s, Syslog::LOG_PID, Syslog::LOG_SYSLOG) do |s|
    #     s.send(self.severity.to_sym, self.category.upcase + ' - ' + self.message)
    #   end
    # end

    class Filter
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :search
      attribute :categories, array: true, default: -> { [] }
      attribute :severities, array: true, default: -> { [] }

      def apply(ret)
        # otherwise a filter with no categories/severities should filter everything
        categories&.compact_blank!
        severities&.compact_blank!
        ret = ret.where(category: categories) if categories.present?
        ret = ret.where(severity: severities) if severities.present?
        ret = ret.where('message LIKE :query', { query: "%#{search}%" }) if search.present?
        ret
      end
    end
  end
end
