module Chaltron
  module Paginating
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend
      helper_method :per_page, :page
    end
    class_methods do
      def paginating(options)
        callback_options = options.extract!(:only, :except, :if, :unless)
        callback = Callback.new(options[:defaults])
        before_action callback, callback_options
      end
    end

    attr_accessor :paginating_defaults

    delegate :per_page, :page, to: :pagination_status

    private

    def pagination_status
      @pagination_status ||= Status.create(pagination_status_params) # standard:disable Rails/SaveBang
    end

    def pagination_status_params
      parameters = %i[page per_page]
      params
        .extract!(*parameters)
        .permit(*parameters)
        .with_defaults(paginating_defaults)
    end
  end
end
