require "test_helper"

class AvailabilityTest < ActiveSupport::TestCase
  setup do
    @availability = availabilities(:one)
    @provider = provider_profiles(:one)
  end

  test "valid availability fixture is valid" do
    assert @availability.valid?
  end

  test "availability requires day of week" do
    @availability.day_of_week = nil

    assert_not @availability.valid?
    assert_includes @availability.errors[:day_of_week], "can't be blank"
  end

  test "availability requires start time" do
    @availability.start_time = nil

    assert_not @availability.valid?
    assert_includes @availability.errors[:start_time], "can't be blank"
  end

  test "availability requires end time" do
    @availability.end_time = nil

    assert_not @availability.valid?
    assert_includes @availability.errors[:end_time], "can't be blank"
  end

  test "end time must be after start time" do
    @availability.start_time = "17:00"
    @availability.end_time = "09:00"

    assert_not @availability.valid?
    assert_includes @availability.errors[:end_time], "must be after start time"
  end

  test "availability cannot overlap on the same day for the same provider" do
    overlapping = @provider.availabilities.new(
      day_of_week: @availability.day_of_week,
      start_time: "10:00",
      end_time: "12:00",
      active: true
    )

    assert_not overlapping.valid?
    assert_includes overlapping.errors[:base],
                    "Availability overlaps with an existing availability"
  end

  test "availability can exist on a different day" do
    availability = @provider.availabilities.new(
      day_of_week: 2,
      start_time: "10:00",
      end_time: "12:00",
      active: true
    )

    assert availability.valid?
  end

  test "availability can exist without overlap on the same day" do
    availability = @provider.availabilities.new(
      day_of_week: @availability.day_of_week,
      start_time: "17:00",
      end_time: "19:00",
      active: true
    )

    assert availability.valid?
  end
end
