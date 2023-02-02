class EscrowSerializer < ActiveModel::Serializer
  attributes :id, :tx, :address

  belongs_to :order
end
