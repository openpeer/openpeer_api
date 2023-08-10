class ListSerializer < ActiveModel::Serializer
  attributes :id, :automatic_approval, :chain_id, :limit_min, :limit_max, :margin_type,
             :margin, :status, :terms, :total_available_amount, :price, :type, :deposit_time_limit,
             :payment_time_limit

  belongs_to :seller
  belongs_to :token
  belongs_to :fiat_currency
  belongs_to :payment_method, serializer: PaymentMethodSerializer
  belongs_to :bank, serializer: BankSerializer

  def price
    return 0 if @instance_options.fetch(:serializer_context_class, nil) == OrderSerializer

    object.price
  end
end
