module Api
  module V1
    class BanksController < BaseController
      def index
        @banks = Rails.cache.fetch(cache_key, expires_in: nil) do
          if params[:currency_id].to_i == -1
            Bank.includes([:fiat_currency])
          else
            Bank.includes([:fiat_currency]).where(fiat_currency_id: [params[:currency_id], nil])
          end
        end
        render json: @banks, each_serializer: BankSerializer, status: :ok, root: 'data'
      end

      private

      def cache_key
        "banks/#{params[:currency_id]}/#{Bank.maximum(:updated_at).to_i}"
      end
    end
  end
end
