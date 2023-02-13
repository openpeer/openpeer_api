class UserSerializer < ActiveModel::Serializer
  attributes :id, :address, :created_at, :trades, :image_url, :name, :twitter, :verified,
    :completion_rate

  attribute :email do
    EmailAddress.munge(object.email) if object.email
  end

  def trades
    object.orders.where(status: :closed).count
  end

  def completion_rate
    orders_count = object.orders.count
    return unless orders_count > 0

    trades.to_f / orders_count.to_f
  end
end
