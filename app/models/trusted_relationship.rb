class TrustedRelationship < ApplicationRecord
  belongs_to :user
  belongs_to :trusted_user, class_name: "User"

  validates :user_id, uniqueness: { scope: :trusted_user_id }
  validate :not_self_reference

  private

  def not_self_reference
    errors.add(:trusted_user, "can't be the same as the user") if user_id == trusted_user_id
  end
end