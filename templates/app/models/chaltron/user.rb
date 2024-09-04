module Chaltron
  class User < ApplicationRecord
    include HasRoles
    include Filterable

    validates :username, presence: true, uniqueness: {case_sensitive: false}
    # Only allow letter, number, underscore and punctuation.
    # see https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
    validates :username, format: /\A[a-zA-Z0-9_.]*\z/
    validate :avatar_variable

    scope :search_by, ->(search) do
      if search.present?
        where("username LIKE :query or fullname LIKE :query or email LIKE :query or department LIKE :query",
          {query: "%#{search}%"})
      end
    end

    has_one_attached :avatar
    has_many :logins

    def display_name
      fullname.presence || username
    end

    def avatar_variable
      return unless avatar.attached?
      return if avatar.variable?

      errors.add(:avatar, :unvariable)
    end
  end
end
