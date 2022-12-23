class FiatCurrency < ApplicationRecord
  validates :code, :name, presence: true
end
