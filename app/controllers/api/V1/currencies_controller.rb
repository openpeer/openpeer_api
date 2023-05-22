module Api
  module V1
    class CurrenciesController < ActionController::API
      def index
        @currencies = Rails.cache.fetch(cache_key, expires_in: nil) do
          FiatCurrency.order(:position)
        end
        render json: @currencies, each_serializer: FiatCurrencySerializer, status: :ok
      end

      private

      def cache_key
        "currencies/#{FiatCurrency.maximum(:updated_at).to_i}"
      end
    end
  end
end
