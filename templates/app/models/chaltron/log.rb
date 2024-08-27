# require 'syslog'
module Chaltron
  class Log < ApplicationRecord
    include Filterable

    enum :severity, {emerg: 0, alert: 1, crit: 2, err: 3, warning: 4, notice: 5, info: 6, debug: 7}, validate: true

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
