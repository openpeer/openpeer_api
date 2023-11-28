class ListSerializer < ActiveModel::Serializer
  attributes :id, :automatic_approval, :chain_id, :limit_min, :limit_max, :margin_type,
             :margin, :status, :terms, :total_available_amount, :price, :type, :deposit_time_limit,
             :payment_time_limit, :accept_only_verified, :escrow_type, :contract, :price_source

  belongs_to :seller
  belongs_to :token
  belongs_to :fiat_currency
  has_many :payment_methods, each_serializer: PaymentMethodSerializer
  has_many :banks, each_serializer: BankSerializer

  def price
    return 0 if @instance_options.fetch(:serializer_context_class, nil) == OrderSerializer

    prices = Rails.cache.fetch(price_cache_key) || []
    index = {
      'binance_min' => 0,
      'binance_median' => 1,
      'binance_max' => 2,
      'coingecko' => 4,
    }.fetch(object.price_source, 4)

    prices[index] || object.price
  end

  def accept_only_verified
    object.accept_only_verified?
  end

  # def token_spot_price
  #   object.token.price_in_currency(object.fiat_currency.code)
  # end

  def contract
    return unless object.escrow_type == 'instant'

    contract = object.seller.contracts.where(chain_id: object.chain_id).order(version: :desc, created_at: :desc).first
    return unless contract

    contract.address
  end

  private

  def price_cache_key
    "prices/#{object.token.symbol.upcase}/#{object.fiat_currency.code.upcase}/#{object.sell_list? ? 'BUY' : 'SELL'}"
  end
end
