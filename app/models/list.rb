class List < ApplicationRecord
  enum status: [:created, :active, :closed]
  enum margin_type: [:fixed, :percentage]

  belongs_to :seller, class_name: 'User'
  belongs_to :token
  belongs_to :fiat_currency

  def as_json(options)
    super({ include: [:fiat_currency, :token, :seller] }.merge(options))
  end
end
