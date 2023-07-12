class Bank < ApplicationRecord
  validates :name, :image, presence: true
  belongs_to :fiat_currency, optional: true
  has_and_belongs_to_many :fiat_currencies
  has_one_attached :image
end
