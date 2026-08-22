class Api::V1::NotificationsController < Api::V1::BaseController
  before_action :set_notification, only: [ :show, :read, :destroy ]

  def index
    notifications = current_user.notifications.order(created_at: :desc)

    render json: {
      notifications: notifications.map { |notification| notification_json(notification) }
    }
  end

  def show
    render json: {
      notification: notification_json(@notification)
    }
  end

  def read
    @notification.update(read: true)

    render json: {
      message: "Notification marked as read",
      notification: notification_json(@notification)
    }
  end

  def read_all
    current_user.notifications.where(read: false).update_all(
      read: true,
      updated_at: Time.current
    )

    render json: {
      message: "All notifications marked as read"
    }
  end

  def destroy
    @notification.destroy

    render json: {
      message: "Notification deleted successfully"
    }
  end

  private

  def set_notification
    @notification = current_user.notifications.find_by(id: params[:id])

    return if @notification

    render json: { error: "Notification not found" }, status: :not_found
  end

  def notification_json(notification)
    {
      id: notification.id,
      booking_id: notification.booking_id,
      notification_type: notification.notification_type,
      message: notification.message,
      read: notification.read,
      created_at: notification.created_at,
      updated_at: notification.updated_at
    }
  end
end
