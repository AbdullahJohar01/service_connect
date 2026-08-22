class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :provider, class_name: "ProviderProfile"
  belongs_to :service_category
  belongs_to :address

  has_one :review, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :status_histories,
           class_name: "BookingStatusHistory",
           dependent: :destroy
  has_many_attached :problem_images
  has_many_attached :supporting_documents

  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2,
    confirmed: 3,
    in_progress: 4,
    completed: 5,
    cancelled: 6
  }

  validates :scheduled_at, presence: true
  validates :estimated_duration, numericality: { greater_than: 0 }
  validates :customer_description, presence: true
  validates :estimated_price, numericality: { greater_than_or_equal_to: 0 }

  validate :provider_is_available
  validate :no_overlapping_booking
  validate :address_belongs_to_customer

  private

  def booking_end_time
    return if scheduled_at.blank? || estimated_duration.blank?

    scheduled_at + estimated_duration.minutes
  end

  def provider_is_available
    return if provider.blank? || scheduled_at.blank? || estimated_duration.blank?

    booking_start = scheduled_at
    booking_end = booking_end_time

    day_of_week = booking_start.wday

    available = provider.availabilities
                         .where(day_of_week: day_of_week, active: true)
                         .where(
                           "start_time <= ? AND end_time >= ?",
                           booking_start.strftime("%H:%M:%S"),
                           booking_end.strftime("%H:%M:%S")
                         )
                         .exists?

    unless available
      errors.add(
        :scheduled_at,
        "is outside the provider's availability"
      )
    end
  end

  def no_overlapping_booking
    return if provider.blank? || scheduled_at.blank? || estimated_duration.blank?

    booking_start = scheduled_at
    booking_end = booking_end_time

    overlapping = Booking
      .where(provider_id: provider.id)
      .where.not(id: id)
      .where.not(status: [ :rejected, :cancelled, :completed ])
      .where(
        "scheduled_at < ? AND (scheduled_at + (estimated_duration * interval '1 minute')) > ?",
        booking_end,
        booking_start
      )

    if overlapping.exists?
      errors.add(
        :scheduled_at,
        "overlaps with an existing booking"
      )
    end
  end

  def address_belongs_to_customer
    return if address.blank? || customer.blank? || address.user_id == customer_id

    errors.add(:address, "must belong to the customer")
  end
end
