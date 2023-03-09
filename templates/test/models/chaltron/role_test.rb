require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "should create role" do
    assert_difference "Chaltron::Role.count" do
      create(:chaltron_role)
    end
  end

  test "name should be present" do
    record = build(:chaltron_role, name: nil)
    assert_not record.valid?
    assert_not_empty record.errors[:name]
  end

  test "name should be unique" do
    role = create(:chaltron_role)
    record = build(:chaltron_role, name: role.name)
    assert_not record.valid?
    assert_not_empty record.errors[:name]
  end
end
