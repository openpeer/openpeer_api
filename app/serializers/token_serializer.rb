class TokenSerializer < ActiveModel::Serializer
  attributes :id, :address, :chain_id, :decimals, :symbol, :name, :coingecko_id,
    :coinmarketcap_id, :gasless, :icon, :minimum_amount, :allow_binance_rates
end
