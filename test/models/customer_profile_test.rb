require "test_helper"

class CustomerProfileTest < ActiveSupport::TestCase
  test "customer profile is valid with valid attributes" do
    profile = customer_profiles(:one)

    assert profile.valid?
  end

  test "customer profile belongs to a user" do
    profile = customer_profiles(:one)

    assert_equal users(:one), profile.user
  end

  test "customer profile requires a user" do
    profile = customer_profiles(:one)
    profile.user = nil

    assert_not profile.valid?
    assert_includes profile.errors[:user], "must exist"
  end
end
