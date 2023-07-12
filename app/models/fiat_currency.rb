class FiatCurrency < ApplicationRecord
  validates :code, :name, presence: true
  has_and_belongs_to_many :banks
end
