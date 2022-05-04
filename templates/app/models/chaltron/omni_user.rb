module Chaltron
  class OmniUser < User
    devise :rememberable, :timeoutable, :trackable, :omniauthable, omniauth_providers: [:ldap]
    # this should be included after devise, because it overrides active_for_authentication? method
    include Enableable
  end
end
