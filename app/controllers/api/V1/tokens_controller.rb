module Api
  module V1
    class TokensController < ActionController::API
      def index
        chain_id_condition = { chain_id: params[:chain_id] } if params[:chain_id]
        @tokens = Rails.cache.fetch(cache_key, expires_in: nil) do
          Token.where(chain_id_condition).order(:position)
        end
        render json: @tokens, each_serializer: TokenSerializer, status: :ok
      end

      private

      def cache_key
        "tokens/#{params[:chain_id]}/#{Token.maximum(:updated_at).to_i}"
      end
    end
  end
end
