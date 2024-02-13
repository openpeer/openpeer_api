class Token < ApplicationRecord
  validates_uniqueness_of :address, scope: :chain_id, case_sensitive: false
  validates :address, :chain_id, :decimals, :coingecko_id, presence: true

  before_create do
    self.address = Eth::Address.new(self.address).checksummed
  end

  def price_in_currency(code)
    code = code.downcase
    Rails.cache.fetch("token/#{self.symbol}/price/#{code}", expires_in: 30.minutes) do
      url = "https://pro-api.coingecko.com/api/v3/simple/price?ids=#{self.coingecko_id}&vs_currencies=#{code}"
      headers = {
        "x-cg-pro-api-key" => ENV['COINGECKO_API_KEY']
      }
      response = RestClient.get(url, headers = headers)
      price = JSON.parse(response.body)[self.coingecko_id][code]
      price ||= coinbase_price_in_currency(code)
      price
    end
  end

  def icon
    image_url || "https://cryptologos.cc/logos/thumbs/#{coinmarketcap_id || coingecko_id}.png"
  end

  private

  def coinbase_price_in_currency(code)
    url = "https://api.coinbase.com/v2/prices/#{self.symbol}-#{code}/spot"
    response = RestClient.get(url)
    JSON.parse(response.body).dig('data').fetch('amount', '0').to_f
  end
end
