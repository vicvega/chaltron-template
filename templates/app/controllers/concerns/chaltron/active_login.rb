module Chaltron
  module ActiveLogin
    private

    def create_login
      ip_address = request.remote_ip
      user_agent = request.user_agent
      device_id = Digest::SHA256.hexdigest("#{ip_address}#{user_agent}#{current_user.id}")
      current_login = current_user.logins.find_or_create_by!(device_id:) do |login|
        login.ip_address = ip_address
        login.user_agent = user_agent
      end
      session[:device_id] = current_login.device_id
    end

    def destroy_login
      current_user.logins.find_by(device_id: session[:device_id])&.destroy
      session.delete :device_id
    end

    def require_login
      return if controller_path == "chaltron/sessions" && action_name == "create"

      current_login = current_user.logins.find_by(device_id: session[:device_id])
      return if current_login.present?

      sign_out current_user
      redirect_to new_local_session_path, alert: I18n.t("chaltron.device_not_recognized")
    end
  end
end
