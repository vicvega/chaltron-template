module Chaltron
  module SessionLogin
    CURRENT_DEVICE_KEY = "device_id"

    def create_login(user, request, session)
      ip_address = request.remote_ip
      user_agent = request.user_agent
      device_id = Digest::SHA256.hexdigest("#{ip_address}#{user_agent}#{user.id}")
      current_login = user.logins.find_or_create_by!(device_id:) do |login|
        login.ip_address = ip_address
        login.user_agent = user_agent
      end
      session[CURRENT_DEVICE_KEY] = current_login.device_id
    end

    def destroy_login(user, session)
      user.logins.find_by(device_id: session[CURRENT_DEVICE_KEY])&.destroy
    end
  end
end
