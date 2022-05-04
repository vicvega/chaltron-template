require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:chaltron_local_user)
  end

  test 'should generate log message after login' do
    assert_difference 'Chaltron::Log.count' do
      post local_session_url, params:
        { local: { login: @user.username, password: @user.password } }
    end
  end

  test 'should generate log message after logout' do
    sign_in @user
    # 2 log messages are generated:
    # - after_set_user
    # - before_logout
    assert_difference 'Chaltron::Log.count', 2 do
      delete destroy_local_session_url
    end
  end
end
