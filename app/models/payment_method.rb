class PaymentMethod < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :banks

  def as_json(options)
    super({ include: [:user, :banks] }.merge(options))
  end
end
