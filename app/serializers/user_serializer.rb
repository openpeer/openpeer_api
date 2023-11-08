class UserSerializer < ActiveModel::Serializer
  attributes :id, :address, :created_at, :trades, :image_url, :name, :twitter, :verified,
    :completion_rate, :timezone, :available_from, :available_to, :weekend_offline

  has_many :contracts do
    object.contracts.order(created_at: :desc)
  end

  attribute :email do
    if object.email
      @instance_options.dig(:params, :show_email) ? object.email : EmailAddress.munge(object.email)
    end
  end

  def trades
    @trades ||= object.orders.where(status: :closed).count
  end

  def completion_rate
    orders_count = object.orders.count
    return unless orders_count > 0

    trades.to_f / orders_count.to_f
  end
end
