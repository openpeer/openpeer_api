class BankSerializer < ActiveModel::Serializer
  attributes :id, :name, :account_info_schema

  attribute :icon do
    "/payment_channel/#{object.name.downcase}.svg"
  end
end
