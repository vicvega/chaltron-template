module Chaltron
  class SessionsController < Devise::SessionsController
    include SessionRateLimiting

    session_rate_limit only: :create
  end
end
