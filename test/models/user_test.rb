require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid user fixture is valid" do
    assert @user.valid?
  end

  test "user requires first name" do
    @user.first_name = nil

    assert_not @user.valid?
    assert_includes @user.errors[:first_name], "can't be blank"
  end

  test "user requires last name" do
    @user.last_name = nil

    assert_not @user.valid?
    assert_includes @user.errors[:last_name], "can't be blank"
  end

  test "user requires email" do
    @user.email = nil

    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "user requires a valid email format" do
    @user.email = "invalid-email"

    assert_not @user.valid?
    assert @user.errors[:email].any?
  end

  test "user email must be unique" do
    duplicate = User.new(
      first_name: "Another",
      last_name: "User",
      email: @user.email,
      password: "password123",
      password_confirmation: "password123",
      phone_number: "03000000003",
      role: :customer,
      status: :active
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "user requires phone number" do
    @user.phone_number = nil

    assert_not @user.valid?
    assert_includes @user.errors[:phone_number], "can't be blank"
  end

  test "user password can authenticate" do
    assert @user.authenticate("password123")
  end

  test "user rejects incorrect password" do
    assert_not @user.authenticate("wrong-password")
  end

  test "user can have customer role" do
    @user.role = :customer

    assert @user.customer?
  end

  test "user can have provider role" do
    @user.role = :provider

    assert @user.provider?
  end

  test "user can have admin role" do
    @user.role = :admin

    assert @user.admin?
  end

  test "user can have active status" do
    @user.status = :active

    assert @user.active?
  end

  test "user can have pending status" do
    @user.status = :pending

    assert @user.pending?
  end
end
