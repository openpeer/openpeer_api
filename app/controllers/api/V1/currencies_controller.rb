module Api
  module V1
    class CurrenciesController < BaseController
      def index
        @currencies = FiatCurrency.all
        render json: @currencies, status: :ok
      end
    end
  end
end
