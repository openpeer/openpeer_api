module Api
  module V1
    class BanksController < BaseController
      def index
        @banks = Rails.cache.fetch(cache_key, expires_in: nil) do
          if params[:currency_id].to_i == -1
            Bank.all
          else
            Bank.left_joins(:fiat_currencies).where(fiat_currencies: { id: [4, nil] })
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
