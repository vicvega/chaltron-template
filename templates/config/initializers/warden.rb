require 'chaltron/ldap/user'

if defined?(Warden)
  Warden::Manager.after_set_user do |user, warden, options|
    # Here you can do a last check on LDAP before authentication
    # E.g.:
    #
    # if user && user.ldap_user?
    #   ldap = Chaltron::LDAP::Connection.new
    #   if ldap.find_by_uid(user.username).entry.enabled != ['true']
    #     scope = options[:scope]
    #     warden.logout(scope)
    #     throw :warden, scope: scope, message: I18n.t('chaltron.not_allowed_to_sign_in')
    #   end
    # end
  end

  # Log after authentication
  Warden::Manager.after_authentication do |user, _warden, options|
    if user
      message = if options[:kind].nil?
                  I18n.t('chaltron.logs.login', user: user.display_name)
                else
                  I18n.t('chaltron.logs.login_omniauth', user: user.display_name, provider: options[:kind])
                end
      Chaltron::Log.create(message: message, category: :login, severity: :info)
    end
  end

  Warden::Manager.before_logout do |user, _warden, _options|
    # Here you can do a callback on LDAP just before logout
    # E.g.:
    #
    # if user.ldap_user?
    #   ldap = Chaltron::LDAP::Connection.new
    #   ldap.update_attributes(user.extern_uid, {
    #     lastLogout: Time.now.strftime('%Y%m%d%H%M%S%z')
    #   })
    # end
    # Log before logout
    if user
      Chaltron::Log.create(
        message: I18n.t('chaltron.logs.logout', user: user.display_name),
        category: :login,
        severity: :info
      )
    end
  end
end
