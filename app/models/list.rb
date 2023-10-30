class List < ApplicationRecord
  enum status: [:created, :active, :closed], _default: :active
  enum margin_type: [:fixed, :percentage]
  enum escrow_type: [:manual, :instant], _default: :manual

  SELL_LIST_TYPE = 'SellList'
  BUY_LIST_TYPE = 'BuyList'

  belongs_to :seller, class_name: 'User'
  belongs_to :token
  belongs_to :fiat_currency
  belongs_to :payment_method, optional: true, class_name: 'ListPaymentMethod' # used for sell lists where the user knows the payment method
  belongs_to :bank, optional: true # used for buy lists where the user only knows what service they want to use
  has_and_belongs_to_many :payment_methods
  has_and_belongs_to_many :banks, join_table: :lists_banks

  has_many :orders

  validate :ensure_bank_or_payment_methods_present
  validates :chain_id, presence: true
  validates :payment_time_limit, numericality: { greater_than_or_equal_to: 15, less_than_or_equal_to: 1440 }


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

  def ensure_bank_or_payment_methods_present
    unless bank_id.present? || payment_methods.present?
      errors.add(:base, "Either bank or payment methods must be present")
    end
  end
end
