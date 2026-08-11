class Availability < ApplicationRecord
  belongs_to :provider_profile

  validates :day_of_week, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :end_time_after_start_time
  validate :no_overlapping_availability

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlapping_availability
    return if start_time.blank? || end_time.blank?

    overlapping = provider_profile.availabilities
                                  .where(day_of_week: day_of_week)
                                  .where.not(id: id)
                                  .where(
                                    "start_time < ? AND end_time > ?",
                                    end_time,
                                    start_time
                                  )

    if overlapping.exists?
      errors.add(:base, "Availability overlaps with an existing availability")
    end
  end
end
