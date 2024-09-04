require "test_helper"

class LoginTest < ActiveSupport::TestCase
  test "should create login" do
    assert_difference "Chaltron::Login.count" do
      create(:chaltron_login)
    end
  end

  test "device_id should be present" do
    record = build(:chaltron_login, device_id: nil)

    assert_not record.valid?
    assert_not_empty record.errors[:device_id]
  end

  test "ip_address should be present" do
    record = build(:chaltron_login, ip_address: nil)

    assert_not record.valid?
    assert_not_empty record.errors[:ip_address]
  end

  test "user should be present" do
    record = build(:chaltron_login, user: nil)

    assert_not record.valid?
    assert_not_empty record.errors[:user]
  end

  test "device_id should be unique" do
    record1 = build(:chaltron_login, device_id: nil)
    record2 = build(:chaltron_login, device_id: record1.device_id)

    assert_not record2.valid?
    assert_not_empty record2.errors[:device_id]
  end
end
