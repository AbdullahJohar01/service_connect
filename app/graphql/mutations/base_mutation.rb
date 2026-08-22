# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    private

    def current_user
      context[:current_user]
    end

    def require_user!
      raise GraphQL::ExecutionError, "Authentication required" unless current_user
      raise GraphQL::ExecutionError, "Account is not active" unless current_user.active?
    end

    def require_customer!
      require_user!

      unless current_user.customer?
        raise GraphQL::ExecutionError, "Customer access required"
      end
    end

    def require_provider!
      require_user!

      unless current_user.provider?
        raise GraphQL::ExecutionError, "Provider access required"
      end
    end

    def require_admin!
      require_user!

      unless current_user.admin?
        raise GraphQL::ExecutionError, "Admin access required"
      end
    end

    def accessible_booking!(id)
      require_user!

      booking = Booking.find_by(id: id)

      raise GraphQL::ExecutionError, "Booking not found" unless booking

      return booking if current_user.admin?

      if current_user.customer? && booking.customer_id == current_user.id
        return booking
      end

      if current_user.provider? &&
         booking.provider_id == current_user.provider_profile&.id
        return booking
      end

      raise GraphQL::ExecutionError, "You cannot access this booking"
    end

    def change_booking_status!(booking, new_status, notes = nil)
      Bookings::ChangeStatus.new(
        booking: booking,
        user: current_user,
        new_status: new_status,
        notes: notes
      ).call
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
