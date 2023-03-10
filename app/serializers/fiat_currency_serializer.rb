class FiatCurrencySerializer < ActiveModel::Serializer
  attributes :id, :code, :name, :country_code, :symbol

  attribute :icon do
    object.country_code
  end
end
