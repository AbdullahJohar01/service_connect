# frozen_string_literal: true

module Mutations
  class MarkAllNotificationsRead < BaseMutation
    description "Mark all notifications belonging to the current user as read"

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve
      require_user!

      current_user.notifications
                  .where(read: false)
                  .update_all(
                    read: true,
                    updated_at: Time.current
                  )

      {
        success: true,
        errors: []
      }
    end
  end
end
