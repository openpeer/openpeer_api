module Api
  module V1
    class BanksController < BaseController
      def index
        @banks = Rails.cache.fetch(cache_key, expires_in: nil) do
          Bank.includes([:fiat_currency]).where(fiat_currency_id: [params[:currency_id], nil])
        end
        render json: @banks, each_serializer: BankSerializer, status: :ok
      end

      private

      def cache_key
        "banks/#{params[:currency_id]}/#{Bank.maximum(:updated_at).to_i}"
      end
    end
  end
end
