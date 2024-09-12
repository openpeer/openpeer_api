# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :address, :unique_identifier, :created_at, :trades, :image_url, :name, :twitter, :verified,
    :completion_rate, :timezone, :available_from, :available_to, :weekend_offline, :online, :telegram_user_id, :telegram_username, :whatsapp_country_code, :whatsapp_number

    def attributes(*args)
      hash = super
      hash.each do |key, value|
        begin
          hash[key] = send(key)
        rescue => e
          Rails.logger.error("Error serializing #{key} for user #{object.id}: #{e.message}")
          hash[key] = nil
        end
      end
      hash
    end

  has_many :contracts do
    object.contracts.order(created_at: :desc)
  end

  attribute :email do
    if object.email
      @instance_options.dig(:params, :show_email) ? object.email : EmailAddress.munge(object.email)
    end
  end

  def trades
    @trades ||= object.orders.where(status: :closed).count + object.imported_orders_count
  end

  def completion_rate
    orders_count = object.orders.joins(:escrow).count + object.imported_orders_count
    return 0 unless orders_count > 0
  
    trades.to_f / orders_count.to_f
  end
end
