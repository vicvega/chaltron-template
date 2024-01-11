module Chaltron
  module HasRoles
    extend ActiveSupport::Concern

    included do
      # standard: disable Rails/HasAndBelongsToMany
      has_and_belongs_to_many :roles, class_name: "Chaltron::Role", foreign_key: "chaltron_role_id",
        association_foreign_key: "chaltron_user_id"
      # standard: enable Rails/HasAndBelongsToMany
    end

    def role?(role)
      roles.include?(Role.find_by(name: role))
    end
  end
end
