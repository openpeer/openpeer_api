class BlockedRelationship < ApplicationRecord
  belongs_to :user
  belongs_to :blocked_user, class_name: "User"

  validates :user_id, uniqueness: { scope: :blocked_user_id }
  validate :not_self_reference

  private

  def not_self_reference
    errors.add(:blocked_user, "can't be the same as the user") if user_id == blocked_user_id
  end
end