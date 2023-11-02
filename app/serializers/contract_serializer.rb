class ContractSerializer < ActiveModel::Serializer
  attributes :id, :chain_id, :address, :version
end
