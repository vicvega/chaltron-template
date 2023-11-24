require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create a new user" do
    assert_difference "Chaltron::User.count" do
      u = create(:chaltron_local_user, with_roles: %w[admin user_admin])

      assert u.role?(:admin)
      assert u.role?(:user_admin)
      assert u.role?("admin")
      assert u.role?("user_admin")
    end
  end

  test "username should be present" do
    record = build(:chaltron_local_user, username: "")

    assert_not record.valid?
    assert_not_empty record.errors[:username]
  end

  test "username should be unique" do
    user = create(:chaltron_local_user)
    record = build(:chaltron_local_user, username: user.username)

    assert_not record.valid?
    assert_not_empty record.errors[:username]

    record = build(:chaltron_local_user, username: user.username.upcase)

    assert_not record.valid?
    assert_not_empty record.errors[:username]
  end

  test "username should not contain special characters" do
    record = build(:chaltron_local_user, username: "user,name")

    assert_not record.valid?
    assert_not_empty record.errors[:username]
  end

  test "should user use email during login" do
    u = build(:chaltron_local_user, username: nil)

    assert_equal u.email, u.login
  end
end
