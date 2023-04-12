module Api
  module V1
    class CurrenciesController < BaseController
      def index
        @currencies = Rails.cache.fetch(cache_key, expires_in: nil) do
          FiatCurrency.all
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
