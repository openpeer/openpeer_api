module Api
  module V1
    class PaymentMethodsController < BaseController
      def index
        @banks = Bank.where(fiat_currency_id: [params[:currency_id], nil])
        render json: @banks, status: :ok
      end
    end
  end
end
