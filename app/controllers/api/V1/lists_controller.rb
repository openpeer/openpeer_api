module Api
  module V1
    class ListsController < BaseController
      def index
        status = List.statuses[params[:status]]
        status_condition = { status: status } if status
        chain_id_condition = { chain_id: params[:chain_id] } if params[:chain_id]
        seller = params[:seller]

        @lists = List.includes(:seller, :token, :fiat_currency).where(status_condition).where(chain_id_condition)
        @lists = @lists.joins(:seller)
                       .where('lower(users.address) = ?', seller.downcase) if seller
        render json: @lists, status: :ok
      end
    end
  end
end
