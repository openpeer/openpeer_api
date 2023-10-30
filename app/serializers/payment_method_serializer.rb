class PaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :values

  belongs_to :bank
end
