class Bank < ApplicationRecord
  validates :name, presence: true
  belongs_to :fiat_currency, optional: true
end
