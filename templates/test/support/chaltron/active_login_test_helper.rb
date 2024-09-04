module Chaltron
  module WardenActiveLoginTestHelper
    def login_as(user, opts = {})
      super
      Warden.on_next_request do |proxy|
        # create a valid active login for test sessions
        ip_address = "127.0.0.1"
        user_agent = nil
        device_id = Digest::SHA256.hexdigest("#{ip_address}#{user_agent}#{user.id}")
        user.logins.find_or_create_by!(device_id:) do |login|
          login.ip_address = ip_address
          login.user_agent = user_agent
        end
        proxy.session_serializer.session[:device_id] = device_id
      end
    end
  end
end

module Warden
  module Test
    module Helpers
      prepend Chaltron::WardenActiveLoginTestHelper
    end
  end
end
