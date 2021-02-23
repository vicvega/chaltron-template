require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should create a new user' do
    Chaltron::Role.create(name: 'admin')
    Chaltron::Role.create(name: 'user_admin')
    assert_difference 'Chaltron::User.count' do
      u = create(:chaltron_user, roles: Chaltron::Role.all)
      assert u.role?(:admin)
      assert u.role?(:user_admin)
      assert u.role?('admin')
      assert u.role?('user_admin')
    end
  end

  test 'username should be present' do
    record = build(:chaltron_user, username: '')
    assert_not record.valid?
    assert_not_empty record.errors[:username]
  end

  test 'username should be unique' do
    user = create(:chaltron_user)
    record = build(:chaltron_user, username: user.username)
    assert_not record.valid?
    assert_not_empty record.errors[:username]

    record = build(:chaltron_user, username: user.username.upcase)
    assert_not record.valid?
    assert_not_empty record.errors[:username]
  end

  test 'username should not contain special characters' do
    record = build(:chaltron_user, username: 'user,name')
    assert_not record.valid?
    assert_not_empty record.errors[:username]
  end
end
