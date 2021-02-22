module Chaltron
  class Role < ApplicationRecord
    has_and_belongs_to_many :users, class_name: 'Chaltron::User', foreign_key: 'chaltron_user_id',
                                    association_foreign_key: 'chaltron_role_id'

    validates :name, presence: true, uniqueness: { case_sensitive: false }
  end
end
