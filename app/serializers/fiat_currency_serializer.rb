class FiatCurrencySerializer < ActiveModel::Serializer
  attributes :id, :code, :name, :country_code, :symbol

  attribute :icon do
    "https://raw.githubusercontent.com/hampusborgos/country-flags/main/png250px/#{object.country_code.downcase}.png"
  end
end
