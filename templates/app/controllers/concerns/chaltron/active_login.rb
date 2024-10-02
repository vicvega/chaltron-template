module Chaltron
  module ActiveLogin
    extend ActiveSupport::Concern
    included do
      helper_method :current_login
      before_action :require_login, if: :login_required?
    end

    private

    def require_login
      return if current_login.present?

      sign_out current_user
      redirect_to new_local_session_path, alert: I18n.t("chaltron.device_not_recognized")
    end

    def current_login
      return unless current_user

      @current_login ||= current_user.logins.find_by(device_id: session[SessionLogin::CURRENT_DEVICE_KEY])
    end

    def login_required?
      return false if controller_path == "chaltron/sessions" && action_name == "create"

      current_user
    end
  end
end
