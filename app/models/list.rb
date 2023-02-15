class List < ApplicationRecord
  enum status: [:created, :active, :closed]
  enum margin_type: [:fixed, :percentage]

  belongs_to :seller, class_name: 'User'
  belongs_to :token
  belongs_to :fiat_currency
  belongs_to :payment_method

  has_many :orders
end
