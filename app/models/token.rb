class Token < ApplicationRecord
  validates_uniqueness_of :address, scope: :chain_id, case_sensitive: false
  validates :address, :chain_id, :decimals, :coingecko_id, presence: true

  before_create do
    self.address = Eth::Address.new(self.address).checksummed
  end

  def price_in_currency(code)
    code = code.downcase
    Rails.cache.fetch("token/#{self.symbol}/price/#{code}", expires_in: 30.minutes) do
      url = "https://api.coingecko.com/api/v3/simple/price?ids=#{self.coingecko_id}&vs_currencies=#{code}"
      response = RestClient.get(url)
      JSON.parse(response.body)[self.coingecko_id][code]
    end
  end
end
