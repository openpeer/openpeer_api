class BankSerializer < ActiveModel::Serializer
  attributes :id, :name, :account_info_schema

  attribute :icon do
    object.image.url if object.image.attached?
  end
end
