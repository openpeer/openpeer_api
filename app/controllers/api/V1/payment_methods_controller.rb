module Api
  module V1
    class PaymentMethodsController < JwtController
      def index
        @payment_methods = current_user.list_payment_methods
                                       .left_joins(bank: :fiat_currencies)
                                       .where(banks_fiat_currencies: { fiat_currency_id: [params[:currency_id], nil]})
        render json: @payment_methods, each_serializer: PaymentMethodSerializer, status: :ok, root: 'data'
      end
    end
  end
end
