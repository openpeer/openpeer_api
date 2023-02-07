class TokenSerializer < ActiveModel::Serializer
  attributes :id, :address, :chain_id, :decimals, :symbol, :name, :coingecko_id

  attribute :icon do
    "https://raw.githubusercontent.com/ErikThiart/cryptocurrency-icons/master/128/#{object.coingecko_id}.png"
  end
end
