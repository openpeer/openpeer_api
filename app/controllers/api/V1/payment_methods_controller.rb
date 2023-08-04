module Api
  module V1
    class PaymentMethodsController < BaseController
      def index
        @payment_methods = ListPaymentMethod.joins(:user).left_joins(bank: :fiat_currencies)
                                            .where(banks_fiat_currencies: { fiat_currency_id: [params[:currency_id], nil]})
                                            .where('lower(users.address) = ?', params[:address].downcase)
        render json: @payment_methods, each_serializer: PaymentMethodSerializer, status: :ok, root: 'data'
      end
    end
  end
end
