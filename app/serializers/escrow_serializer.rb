class EscrowSerializer < ActiveModel::Serializer
  attributes :id, :tx, :address, :created_at
end
