require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "notification is valid with required fields" do
    notification = notifications(:one)

    assert notification.valid?
  end

  test "notification requires notification type" do
    notification = notifications(:one)
    notification.notification_type = nil

    assert_not notification.valid?
    assert_includes notification.errors.full_messages, "Notification type can't be blank"
  end

  test "notification requires message" do
    notification = notifications(:one)
    notification.message = nil

    assert_not notification.valid?
    assert_includes notification.errors.full_messages, "Message can't be blank"
  end
end
