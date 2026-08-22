# frozen_string_literal: true

module Mutations
  class MarkNotificationRead < BaseMutation
    description "Mark a notification as read"

    field :notification, Types::NotificationType, null: true
    field :errors, [ String ], null: false

    argument :id, ID, required: true

    def resolve(id:)
      require_user!

      notification = current_user.notifications.find_by(id: id)

      unless notification
        return {
          notification: nil,
          errors: [ "Notification not found" ]
        }
      end

      if notification.update(read: true)
        {
          notification: notification,
          errors: []
        }
      else
        {
          notification: nil,
          errors: notification.errors.full_messages
        }
      end
    end
  end
end
