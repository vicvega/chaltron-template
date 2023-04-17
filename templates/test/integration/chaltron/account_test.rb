require "test_helper"

class AccountTest < ActionDispatch::IntegrationTest
  include AbstractController::Translation

  setup do
    @user = create(:chaltron_local_user)
    sign_in @user
  end

  test "user should edit account data" do
    get root_url

    assert_select "a[href='#{chaltron_self_user_show_path}']", t("chaltron.menu.self_show")

    get chaltron_self_user_show_path
    assert_select "li.list-group-item" do
      assert_select "strong", @user.email
    end
    assert_select "a[href='#{chaltron_self_user_edit_path}']", t("chaltron.self_user.show.edit")

    get chaltron_self_user_edit_path
    assert_select "form#edit_chaltron_user[action='#{chaltron_self_user_update_path}']" do
      assert_select "input[name='chaltron_user[fullname]'][value=\"#{@user.fullname}\"]"
      assert_select "input[name='chaltron_user[email]'][value='#{@user.email}']"
    end

    new_email = "test@hogwarts.co.uk"
    patch chaltron_self_user_update_path, params: {
      chaltron_user: {
        email: new_email
      }
    }
    follow_redirect!

    assert_select ".alert.alert-info", "#{t("chaltron.flash.notice")}: #{t("chaltron.users.self_updated")}"
    assert_select "li.list-group-item" do
      assert_select "strong", new_email
    end
    assert_equal new_email, @user.reload.email
  end

  test "user should change password" do
    get root_url

    assert_select "a[href='#{chaltron_self_user_show_path}']", t("chaltron.menu.self_show")

    get chaltron_self_user_show_path
    assert_select "li.list-group-item" do
      assert_select "strong", @user.email
    end
    assert_select "a[href='#{chaltron_self_user_change_password_path}']", t("chaltron.self_user.show.change_password")

    get chaltron_self_user_change_password_path
    assert_select "form#edit_chaltron_user[action='#{chaltron_self_user_update_password_path}']" do
      assert_select "input[name='chaltron_user[current_password]']"
      assert_select "input[name='chaltron_user[password]']"
      assert_select "input[name='chaltron_user[password_confirmation]']"
    end
    new_password = "password.1"
    patch chaltron_self_user_update_password_path, params: {
      chaltron_user: {
        current_password: @user.password,
        password: new_password,
        password_confirmation: new_password
      }
    }
    follow_redirect!

    assert_select ".alert.alert-info", "#{t("chaltron.flash.notice")}: #{t("chaltron.users.password_changed")}"
  end

  test "user should not change password if missing new password" do
    patch chaltron_self_user_update_password_path, params: {
      chaltron_user: {
        current_password: @user.password,
        password: ""
      }
    }

    assert_response :unprocessable_entity
  end
end
