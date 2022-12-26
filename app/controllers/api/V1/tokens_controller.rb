module Api
  module V1
    class TokensController < BaseController
      def index
        chain_id_condition = { chain_id: params[:chain_id] } if params[:chain_id]
        @tokens = Token.where(chain_id_condition)
        render json: @tokens, status: :ok
      end
    end
  end
end
