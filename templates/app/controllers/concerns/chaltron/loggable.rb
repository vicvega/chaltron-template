module Chaltron
  module Loggable
    extend ActiveSupport::Concern

    class_methods do
      def loggable(options)
        category = options[:category]
        return if category.nil?

        callback_options = options.extract!(:only, :except, :if, :unless)
        callback = Callback.new(category)
        before_action callback, callback_options
      end
    end

    attr_accessor :default_log_category

    def info(message, category: nil)
      create_log_message(message:, category:, severity: :info)
    end

    def debug(message, category: nil)
      create_log_message(message:, category:, severity: :debug)
    end

    def error(message, category: nil)
      create_log_message(message:, category:, severity: :err)
    end

    private

    def create_log_message(options)
      options.compact_blank!
      Log.create!(
        message: options.fetch(:message),
        category: options.fetch(:category, default_log_category || self.class.to_s.downcase),
        severity: options.fetch(:severity)
      )
    end
  end
end
