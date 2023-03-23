class Dispute < ApplicationRecord
  belongs_to :order
  has_many :user_disputes
  belongs_to :winner, class_name: 'User', optional: true


  scope :active, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
end
