require 'test_helper'

class LogsControllerTest < ActionDispatch::IntegrationTest
  def setup
    admin_role = create(:chaltron_role, name: :admin)
    @log = create(:chaltron_log)
    @admin = create(:chaltron_local_user, roles: [admin_role])
  end

  test 'should not get index if not authenticated' do
    get chaltron_logs_url
    assert_response :redirect
  end

  test 'should not get index if not authorized' do
    get chaltron_logs_url
    sign_in create(:chaltron_local_user)
    assert_response :redirect
  end

  test 'should get index if authorized' do
    sign_in @admin
    get chaltron_logs_url
    assert_response :success
  end

  test 'should get show' do
    sign_in @admin
    get chaltron_log_url(@log)
    assert_response :success
  end
end
