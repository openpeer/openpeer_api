class PaymentMethod < ApplicationRecord
  belongs_to :user
  belongs_to :bank
  has_many :lists

  def as_json(options)
    super({ include: [:user, :bank] }.merge(options))
  end
end
