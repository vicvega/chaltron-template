module Chaltron
  class User < ApplicationRecord
    include Enableable
    include HasRoles
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :recoverable, :rememberable, :validatable,
           :timeoutable, :trackable, :omniauthable

    validates :username, presence: true, uniqueness: { case_sensitive: false }
    # Only allow letter, number, underscore and punctuation.
    # see https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
    validates :username, format: /\A[a-zA-Z0-9_.]*\z/

    validate :avatar_variable

    has_one_attached :avatar

    attr_writer :login

    def self.search(search)
      if search
        where('username LIKE :query or fullname LIKE :query or email LIKE :query', { query: "%#{search}%" })
      else
        all
      end
    end

    def login
      @login || username || email
    end

    def display_name
      fullname.presence || username
    end

    def ldap_user?
      provider == 'ldap'
    end

    # override devise method to allow sign in with email or username
    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if (login = conditions.delete(:login))
        where(conditions.to_h)
          .find_by(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }])
      elsif conditions.key?(:username) || conditions.key?(:email)
        find_by(conditions.to_h)
      end
    end

    # override devise method to check if user account is active
    def active_for_authentication?
      super && enabled?
    end

    def inactive_message
      enabled? ? super : I18n.t('chaltron.users.inactive_message')
    end

    def avatar_variable
      return unless avatar.attached?
      return if avatar.variable?

      errors.add(:avatar, :unvariable)
    end
  end
end
