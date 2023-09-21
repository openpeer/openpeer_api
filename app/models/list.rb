class List < ApplicationRecord
  enum status: [:created, :active, :closed], _default: :active
  enum margin_type: [:fixed, :percentage]
  SELL_LIST_TYPE = 'SellList'
  BUY_LIST_TYPE = 'BuyList'

  belongs_to :seller, class_name: 'User'
  belongs_to :token
  belongs_to :fiat_currency
  belongs_to :payment_method, optional: true, class_name: 'ListPaymentMethod' # used for sell lists where the user knows the payment method
  belongs_to :bank, optional: true # used for buy lists where the user only knows what service they want to use

  has_many :orders

  validate :ensure_bank_or_payment_method_present
  validates :chain_id, presence: true

  def price
    if fixed?
      margin
    else
      api_price = token.price_in_currency(fiat_currency.code)
      api_price + ((api_price * margin) / 100)
    end
  end

  [SELL_LIST_TYPE, BUY_LIST_TYPE].each do |type|
    define_method("#{type.underscore}?") { self.type == type }
  end

  protected

  def ensure_bank_or_payment_method_present
    unless bank_id.present? || payment_method_id.present?
      errors.add(:base, "Either bank or payment method must be present")
    end
  end
end
