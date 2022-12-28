module Api
  module V1
    class PaymentMethodsController < BaseController
      def index
        @payment_methods = PaymentMethod.joins(:user)
                                        .where('lower(users.address) = ?', params[:address].downcase)
        render json: @payment_methods, status: :ok
      end
    end
  end
end
