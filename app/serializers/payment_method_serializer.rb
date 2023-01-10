class PaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :account_number, :account_name

  belongs_to :user
  belongs_to :bank
end
