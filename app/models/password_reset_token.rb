class PasswordResetToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> {
    where(used_at: nil)
      .where("expires_at > ?", Time.current)
  }

  def active?
    used_at.nil? && expires_at.future?
  end

  def mark_used!
    update!(used_at: Time.current)
  end
end
