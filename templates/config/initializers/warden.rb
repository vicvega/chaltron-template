if defined?(Warden)
  Warden::Manager.after_authentication do |user, warden, options|
    include Chaltron::SessionLogin

    if user
      message = if options[:kind].nil?
        I18n.t("chaltron.logs.login", user: user.display_name)
      else
        I18n.t("chaltron.logs.login_omniauth", user: user.display_name, provider: options[:kind])
      end
      # Log after authentication
      Chaltron::Log.create!(message: message, category: :login, severity: :info)
      # create login and save current device in session
      create_login(user, warden.request, warden.session_serializer.session)
    end
  end

  Warden::Manager.before_logout do |user, warden, _options|
    include Chaltron::SessionLogin

    if user
      # Log before logout
      Chaltron::Log.create!(
        message: I18n.t("chaltron.logs.logout", user: user.display_name),
        category: :login,
        severity: :info
      )
      # destroy login (session is automatically cleared on logout)
      destroy_login(user, warden.session_serializer.session)
    end
  end
end
