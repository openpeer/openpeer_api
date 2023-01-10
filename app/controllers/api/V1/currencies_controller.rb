module Api
  module V1
    class CurrenciesController < BaseController
      def index
        @currencies = FiatCurrency.all
        render json: @currencies, each_serializer: FiatCurrencySerializer, status: :ok
      end
    end
  end
end
