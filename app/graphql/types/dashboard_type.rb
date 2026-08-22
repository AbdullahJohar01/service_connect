module Types
  class DashboardType < Types::BaseObject
    field :total_customers, Integer, null: false
    field :total_providers, Integer, null: false
    field :pending_provider_approvals, Integer, null: false
    field :total_bookings, Integer, null: false
    field :completed_bookings, Integer, null: false
    field :cancelled_bookings, Integer, null: false
    field :platform_revenue, Float, null: false
    field :average_booking_value, Float, null: false
  end
end
