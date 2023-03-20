class TokenSerializer < ActiveModel::Serializer
  attributes :id, :address, :chain_id, :decimals, :symbol, :name, :coingecko_id,
    :coinmarketcap_id, :gasless

  attribute :icon do
    "https://cryptologos.cc/logos/thumbs/#{object.coinmarketcap_id || object.coingecko_id}.png"
  end
end
