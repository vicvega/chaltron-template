require 'test_helper'

class AccountTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:chaltron_user)
    sign_in @user
  end

  test 'user should edit account data' do
    get root_url
    assert_select "a[href='#{self_show_chaltron_users_path}']", I18n.t('chaltron.menu.self_show')

    get self_show_chaltron_users_path
    assert_select 'li.list-group-item' do
      assert_select 'strong', @user.email
    end
    assert_select "a[href='#{self_edit_chaltron_users_path}']", I18n.t('chaltron.users.self_show.edit')

    get self_edit_chaltron_users_path
    assert_select "form#edit_chaltron_user[action='#{self_update_chaltron_users_path}']" do
      assert_select "input[name='chaltron_user[fullname]'][value='#{@user.fullname}']"
      assert_select "input[name='chaltron_user[email]'][value='#{@user.email}']"
    end

    new_email = 'test@hogwarts.co.uk'
    patch self_update_chaltron_users_path, params: {
      chaltron_user: {
        email: new_email
      }
    }
    follow_redirect!

    assert_select '.alert.alert-info', "#{I18n.t('chaltron.flash.notice')}: #{I18n.t('chaltron.users.self_updated')}"
    assert_select 'li.list-group-item' do
      assert_select 'strong', new_email
    end
    assert_equal new_email, @user.reload.email
  end

  test 'user should change password' do
    get root_url
    assert_select "a[href='#{self_show_chaltron_users_path}']", I18n.t('chaltron.menu.self_show')

    get self_show_chaltron_users_path
    assert_select 'li.list-group-item' do
      assert_select 'strong', @user.email
    end
    assert_select "a[href='#{self_edit_chaltron_users_path}']", I18n.t('chaltron.users.self_show.edit')

    get change_password_chaltron_users_path
    assert_select "form#edit_chaltron_user[action='#{self_update_chaltron_users_path}']" do
      assert_select "input[name='chaltron_user[password]']"
      assert_select "input[name='chaltron_user[password_confirmation]']"
    end
    new_password = 'password.1'
    patch self_update_chaltron_users_path, params: {
      chaltron_user: {
        password: new_password,
        password_confirmation: new_password
      }
    }
    follow_redirect!

    assert_select '.alert.alert-info', "#{I18n.t('chaltron.flash.notice')}: #{I18n.t('chaltron.users.self_updated')}"
  end
end
