class List < ApplicationRecord
  enum status: [:created, :active, :closed]
  enum margin_type: [:fixed, :percentage]

  belongs_to :seller, class_name: 'User'
  belongs_to :token
  belongs_to :fiat_currency
  belongs_to :payment_method

  has_many :orders

  def price
    if fixed?
      margin
    else
      api_price = token.price_in_currency(fiat_currency.code)
      api_price + ((api_price * margin) / 100)
    end
  end
end
