require "test_helper"

class ProviderServiceTest < ActiveSupport::TestCase
  setup do
    @provider = provider_profiles(:one)
    @category = service_categories(:one)
  end

  test "provider service is valid with valid attributes" do
    service = ProviderService.new(
      provider_profile: @provider,
      service_category: @category,
      description: "Electrical installation",
      base_price: 1500,
      duration_minutes: 60,
      active: true
    )

    assert service.valid?
  end

  test "base price must be greater than zero" do
    service = ProviderService.new(
      provider_profile: @provider,
      service_category: @category,
      description: "Electrical installation",
      base_price: 0,
      duration_minutes: 60,
      active: true
    )

    assert_not service.valid?
    assert_includes service.errors.full_messages,
                    "Base price must be greater than 0"
  end

  test "duration must be greater than zero" do
    service = ProviderService.new(
      provider_profile: @provider,
      service_category: @category,
      description: "Electrical installation",
      base_price: 1500,
      duration_minutes: 0,
      active: true
    )

    assert_not service.valid?
    assert_includes service.errors.full_messages,
                    "Duration minutes must be greater than 0"
  end
end
