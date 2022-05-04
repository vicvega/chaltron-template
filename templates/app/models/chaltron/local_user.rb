module Chaltron
  class LocalUser < User
    devise :database_authenticatable, :recoverable, :rememberable, :validatable,
           :timeoutable, :trackable
    # this should be included after devise, because it overrides active_for_authentication? method
    include Enableable

    attr_writer :login

    def login
      @login || username || email
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
  end
end
