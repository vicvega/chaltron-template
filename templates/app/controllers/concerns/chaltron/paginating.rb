module Chaltron
  module Paginating
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend
      helper_method :per_page, :page
    end

    attr_accessor :paginating_defaults
    delegate :per_page, :page, to: :pagination_status

    def paginates(defaults: {})
      self.paginating_defaults = defaults
    end

    class Status
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations
      extend Chaltron::CreateValidOrResetParams

      attribute :per_page, :integer, default: Pagy::DEFAULT[:items]
      attribute :page, :integer, default: 1

      validates_numericality_of :page, :per_page, greater_than: 0, only_integer: true
    end

    private

    def pagination_status
      @pagination_status ||= Status.create_valid(pagination_status_params)
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
