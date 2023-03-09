class BankSerializer < ActiveModel::Serializer
  attributes :id, :name, :account_info_schema
  belongs_to :fiat_currency

  attribute :icon do
    "/payment_channel/#{object.name.downcase}.svg"
  end
end
