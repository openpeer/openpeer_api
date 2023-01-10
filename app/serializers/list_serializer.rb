class ListSerializer < ActiveModel::Serializer
  attributes :id, :automatic_approval, :chain_id, :limit_min, :limit_max, :margin_type,
             :margin, :status, :terms, :total_available_amount

  belongs_to :seller
  belongs_to :token
  belongs_to :fiat_currency
  belongs_to :payment_method, serializer: PaymentMethodSerializer
end
