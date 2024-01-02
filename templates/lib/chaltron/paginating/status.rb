module Chaltron
  module Paginating
    class Status
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations
      extend Chaltron::CreateValidOrResetParams

      attribute :per_page, :integer, default: Pagy::DEFAULT[:items]
      attribute :page, :integer, default: 1

      validates_numericality_of :page, :per_page, greater_than: 0, only_integer: true
    end
  end
end
