require "chaltron/ldap/user"

module Chaltron
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include SessionRateLimiting

    session_rate_limit

    def ldap
      # puts '##########################################'
      # puts oauth.inspect
      # puts '##########################################'
      # We only find ourselves here
      # if the authentication to LDAP was successful.
      user = Chaltron::Ldap::User.find_or_create(oauth, Chaltron.ldap_allow_all)
      if user.nil?
        redirect_to new_local_session_url, alert: t("chaltron.not_allowed_to_sign_in")
      else
        store_location_for(user, stored_location_for(:local))
        user.remember_me = params[:remember_me] if user.persisted?
        sign_in_and_redirect(user, event: :authentication, kind: "LDAP")
        set_flash_message(:notice, :success, kind: "LDAP")
      end
    end

    private

    def oauth
      @oauth ||= request.env["omniauth.auth"]
    end

    def after_omniauth_failure_path_for(_scope)
      new_local_session_path
    end
  end
end
