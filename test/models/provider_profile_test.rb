require "test_helper"

class ProviderProfileTest < ActiveSupport::TestCase
  test "provider profile is valid with valid attributes" do
    profile = provider_profiles(:one)

    assert profile.valid?
  end

  test "provider profile belongs to a user" do
    profile = provider_profiles(:one)

    assert_equal users(:two), profile.user
  end

  test "provider profile has many provider services" do
    profile = provider_profiles(:one)

    assert_respond_to profile, :provider_services
  end

  test "provider profile has many availabilities" do
    profile = provider_profiles(:one)

    assert_respond_to profile, :availabilities
  end

  test "provider profile has many bookings" do
    profile = provider_profiles(:one)

    assert_respond_to profile, :bookings
  end

  test "provider profile has many reviews" do
    profile = provider_profiles(:one)

    assert_respond_to profile, :reviews
  end

  test "provider profile requires a user" do
    profile = provider_profiles(:one)
    profile.user = nil

    assert_not profile.valid?
    assert_includes profile.errors[:user], "must exist"
  end

  test "provider profile requires a business name" do
    profile = provider_profiles(:one)
    profile.business_name = nil

    assert_not profile.valid?
    assert_includes profile.errors[:business_name], "can't be blank"
  end

  test "experience years cannot be negative" do
    profile = provider_profiles(:one)
    profile.experience_years = -1

    assert_not profile.valid?
    assert profile.errors[:experience_years].any?
  end

  test "hourly rate must be greater than zero" do
    profile = provider_profiles(:one)
    profile.hourly_rate = 0

    assert_not profile.valid?
    assert profile.errors[:hourly_rate].any?
  end

  test "provider profile has approval status enum" do
    profile = provider_profiles(:one)

    assert_equal "approved", profile.approval_status
    assert profile.approved?
    assert_not profile.pending?
    assert_not profile.rejected?
  end

  test "provider profile can be pending" do
    profile = provider_profiles(:one)

    profile.approval_status = :pending

    assert profile.valid?
    assert profile.pending?
  end

  test "provider profile can be rejected" do
    profile = provider_profiles(:one)

    profile.approval_status = :rejected

    assert profile.valid?
    assert profile.rejected?
  end
end
