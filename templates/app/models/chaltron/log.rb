# require 'syslog'
module Chaltron
  class Log < ApplicationRecord
    include Filterable

    enum :severity, %i[emerg alert crit err warning notice info debug], validate: true

    validates :severity, :category, :message, presence: true

    before_validation :truncate_message

    # after_create :to_syslog

    scope :search_by, ->(search) do
      where("message LIKE :query", {query: "%#{search}%"}) if search.present?
    end

    private

    def truncate_message
      self.message = message&.truncate(1000)
    end

    # def to_syslog
    #   Syslog.open(Rails.application.class.parent.to_s, Syslog::LOG_PID, Syslog::LOG_SYSLOG) do |s|
    #     s.send(self.severity.to_sym, self.category.upcase + ' - ' + self.message)
    #   end
    # end
  end
end
