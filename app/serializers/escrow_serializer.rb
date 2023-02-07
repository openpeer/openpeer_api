class EscrowSerializer < ActiveModel::Serializer
  attributes :id, :tx, :address
end
