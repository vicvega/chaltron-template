module Chaltron
  class SessionsController < Devise::SessionsController
    include SessionRateLimiting
    include ActiveLogin

    session_rate_limit only: :create

    def create
      super do |user|
        if user.persisted?
          create_login
          Log.create!(
            message: I18n.t("chaltron.logs.login", user: user.display_name),
            category: :login,
            severity: :info
          )
        end
      end
    end

    def destroy
      destroy_login
      Chaltron::Log.create!(
        message: I18n.t("chaltron.logs.logout", user: current_user.display_name),
        category: :login,
        severity: :info
      )
      super
    end
  end
end
