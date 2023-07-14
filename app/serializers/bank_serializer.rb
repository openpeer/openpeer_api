class BankSerializer < ActiveModel::Serializer
  attributes :id, :name, :account_info_schema

  attribute :icon do
    # object.image.url if object.image.attached?
    "/payment_channel/#{object.name.downcase}.svg"
  end

  attribute :image do
    object.image.url if object.image.attached?
  end
end
