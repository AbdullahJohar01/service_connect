require "test_helper"

class AddressTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "address is valid with valid attributes" do
    address = Address.new(
      user: @user,
      label: "Home",
      street: "123 Main Street",
      city: "Karachi",
      postal_code: "75000",
      latitude: 24.8607,
      longitude: 67.0011,
      is_default: true
    )

    assert address.valid?
  end

  test "address belongs to a user" do
    address = addresses(:one)

    assert_equal @user.id, address.user_id
    assert_equal @user, address.user
  end

  test "user can have multiple addresses" do
    first_address = addresses(:one)

    second_address = Address.create!(
      user: @user,
      label: "Office",
      street: "456 Business Avenue",
      city: "Karachi",
      postal_code: "75500",
      latitude: 24.9000,
      longitude: 67.1000,
      is_default: false
    )

    assert_equal 2, @user.addresses.count
    assert_includes @user.addresses, first_address
    assert_includes @user.addresses, second_address
  end
end
