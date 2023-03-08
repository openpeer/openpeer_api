class PaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :values

  belongs_to :user
  belongs_to :bank
end
