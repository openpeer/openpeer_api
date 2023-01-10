class PaymentMethod < ApplicationRecord
  belongs_to :user
  belongs_to :bank
  has_many :lists
end
