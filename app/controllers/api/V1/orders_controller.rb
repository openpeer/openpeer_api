module Api
  module V1
    class OrdersController < BaseController
      def index
        @orders = Order.from_user(params[:address].downcase)
                       .where(list: { chain_id: params[:chainId] })
        render json: @orders, each_serializer: OrderSerializer, include: '**', status: :ok
      end

      def create
        if JSON.parse(params[:order].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @order = Order.new(order_params)
            @buyer = User.where('lower(address) = ?', params[:address].downcase).first ||
                     User.create(address: Eth::Address.new(params[:address]).checksummed)
            @order.buyer = @buyer
            if @order.save
              render json: @order, serializer: OrderSerializer, status: :ok
            else
              render json: { message: 'Order not created', errors: @order.errors }, status: :ok
            end
          end
        end
      end

      def show
        @order = Order.find_by(uuid: params[:id])
        render json: @order, serializer: OrderSerializer, include: "**", status: :ok
      end

      protected

      def order_params
        params.require(:order).permit(:fiat_amount, :token_amount, :price, :list_id)
      end
    end
  end
end
