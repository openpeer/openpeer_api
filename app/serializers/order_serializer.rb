class OrderSerializer < ActiveModel::Serializer
  attributes :id, :fiat_amount, :status, :tx_hash, :token_amount, :price, :uuid, :cancelled_at

  belongs_to :buyer
  belongs_to :list
  has_one :escrow
end
