class FiatCurrency < ApplicationRecord
  validates :code, :name, presence: true
  has_and_belongs_to_many :banks

  enum default_price_source: [:coingecko, :binance_median, :binance_min, :binance_max], _default: :coingecko
end
