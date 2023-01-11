module Api
  module V1
    class BanksController < BaseController
      def index
        @banks = Bank.includes([:fiat_currency]).where(fiat_currency_id: [params[:currency_id], nil])
        render json: @banks, each_serializer: BankSerializer, status: :ok
      end
    end
  end
end
