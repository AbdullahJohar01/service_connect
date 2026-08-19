require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "message is valid with valid attributes" do
    message = messages(:one)

    assert message.valid?
  end

  test "message belongs to a booking" do
    message = messages(:one)

    assert_equal bookings(:one), message.booking
  end

  test "message belongs to a sender" do
    message = messages(:one)

    assert_equal message.sender, users(:one)
  end

  test "message requires a booking" do
    message = messages(:one)
    message.booking = nil

    assert_not message.valid?
    assert_includes message.errors[:booking], "must exist"
  end

  test "message requires a sender" do
    message = messages(:one)
    message.sender = nil

    assert_not message.valid?
    assert_includes message.errors[:sender], "must exist"
  end

  test "message requires content" do
    message = messages(:one)
    message.content = nil

    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end
end
