module Api
  module V1
    class OrdersController < JwtController
      def index
        @orders = Order.from_user(current_user.address)
                       .where(list: { chain_id: params[:chain_id] })
        render json: @orders, each_serializer: OrderSerializer, include: '**', status: :ok
      end

      def create
        if JSON.parse(params[:order].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @order = Order.new(order_params)
            @order.buyer = current_user
            if @order.save
              NotificationWorker.perform_async(NotificationWorker::NEW_ORDER, @order.id)
              render json: @order, serializer: OrderSerializer, status: :ok
            else
              render json: { message: 'Order not created', errors: @order.errors }, status: :ok
            end
          end
        end
      end

      def show
        @order = Order.from_user(current_user.address).find_by(uuid: params[:id])
        render json: @order, serializer: OrderSerializer, include: "**", status: :ok
      end

      def cancel
        @order = Order.from_user(current_user.address).find_by(uuid: params[:id])
        @order.cancel(current_user)

        ActionCable.server.broadcast("OrdersChannel_#{@order.uuid}",
          ActiveModelSerializers::SerializableResource.new(@order, include: '**').to_json)

        render json: @order, serializer: OrderSerializer, include: "**", status: :ok
      end

      protected

      def order_params
        params.require(:order).permit(:fiat_amount, :token_amount, :price, :list_id)
      end
    end
  end
end
