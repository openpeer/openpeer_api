class BankSerializer < ActiveModel::Serializer
  attributes :id, :name
  belongs_to :fiat_currency

  attribute :icon do
    "/payment_channel/#{object.name.downcase}.svg"
  end
end
