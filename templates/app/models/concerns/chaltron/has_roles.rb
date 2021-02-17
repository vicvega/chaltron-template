module Chaltron
  module HasRoles
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :roles
    end

    def role?(role)
      roles.include?(Role.find_by_name(role))
    end
  end
end
