module Chaltron
  module HasRoles
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :roles, class_name: "Chaltron::Role", foreign_key: "chaltron_role_id",
        association_foreign_key: "chaltron_user_id"
    end

    def role?(role)
      roles.include?(Role.find_by(name: role))
    end
  end
end
