class Bank < ApplicationRecord
  validates :name, presence: true
  validates :image, presence: true, if: -> { !Rails.env.development? }
  has_and_belongs_to_many :fiat_currencies
  has_one_attached :image
end
