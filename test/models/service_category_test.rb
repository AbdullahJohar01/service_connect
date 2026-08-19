require "test_helper"

class ServiceCategoryTest < ActiveSupport::TestCase
  test "service category can be created with valid attributes" do
    category = ServiceCategory.new(
      name: "Cleaning",
      description: "Home and office cleaning services",
      active: true
    )

    assert category.valid?
  end

  test "service category can have many provider services" do
    category = service_categories(:one)

    assert_respond_to category, :provider_services
  end

  test "service category can have many bookings" do
    category = service_categories(:one)

    assert_respond_to category, :bookings
  end
end
