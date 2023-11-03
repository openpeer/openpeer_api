class FiatCurrencySerializer < ActiveModel::Serializer
  attributes :id, :code, :name, :country_code, :symbol, :allow_binance_rates, :default_price_source

  attribute :icon do
    object.country_code
  end
end
