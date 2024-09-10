require "test_helper"
module Chaltron
  class LoginsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:chaltron_local_user)
      @login = create(:chaltron_login, user: @user)
    end

    test "should not access if not authenticated" do
      delete chaltron_login_url(@login)

      assert_redirected_to new_local_session_path
    end

    test "users cannot destroy others' logins" do
      sign_in(create(:chaltron_local_user))
      delete chaltron_login_url(@login)

      assert_redirected_to :root
      assert_equal I18n.t("unauthorized.manage.all"), flash[:alert]
    end

    test "users can destroy their own logins" do
      sign_in(@user)

      assert Chaltron::Login.exists?(@login.id)
      delete chaltron_login_url(@login)

      refute Chaltron::Login.exists?(@login.id)
      assert_redirected_to chaltron_self_user_show_path
    end
  end
end
