class OrderSerializer < ActiveModel::Serializer
  attributes :id, :fiat_amount, :status, :token_amount, :price, :uuid, :cancelled_at,
    :created_at, :trade_id, :deposit_time_limit, :payment_time_limit

  belongs_to :seller, serializer: UserSerializer
  belongs_to :buyer, serializer: UserSerializer
  belongs_to :list
  belongs_to :payment_method
  has_one :escrow
  has_one :dispute
end
