class PaymentMethod < ApplicationRecord
  belongs_to :user, :bank

  def as_json(options)
    super({ include: [:user, :bank] }.merge(options))
  end
end
