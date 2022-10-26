module Chaltron
  module Loggable
    extend ActiveSupport::Concern

    module ClassMethods
      def log_category
        defined?(@log_category) ? @log_category : to_s.downcase
      end

      def default_log_category(cat)
        @log_category = cat.to_s
      end
    end

    #
    # Utilities for logging
    #
    def info(message, category = nil)
      create_log_message(message, category, :info)
    end

    def debug(message, category = nil)
      create_log_message(message, category, :debug)
    end

    def error(message, category = nil)
      create_log_message(message, category, :err)
    end

    private

    def create_log_message(message, category, severity)
      category ||= self.class.log_category
      Log.create(
        message: message,
        category: category.to_s,
        severity: severity.to_s
      )
    end
  end
end
