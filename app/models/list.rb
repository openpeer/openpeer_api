class List < ApplicationRecord
  enum status: [:created, :active, :closed]
  enum margin_type: [:fixed, :percentage]
  SELL_LIST_TYPE = 'SellList'
  BUY_LIST_TYPE = 'BuyList'

  belongs_to :seller, class_name: 'User'
  belongs_to :token
  belongs_to :fiat_currency
  belongs_to :payment_method, optional: true
  belongs_to :bank, optional: true

  has_many :orders

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
end
