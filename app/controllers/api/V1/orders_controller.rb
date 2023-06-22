module Api
  module V1
    class OrdersController < JwtController
      def index
        @orders = Order.joins(:list).from_user(current_user.address)
                       .where(list: { chain_id: params[:chain_id] })
        render json: @orders, each_serializer: OrderSerializer, include: '**', status: :ok, root: 'data'
      end

      def create
        if JSON.parse(params[:order].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @order = Order.new(order_params)

            if @order.list.buy_list?
              @order.seller = current_user
              @order.buyer = @order.list.seller
            else
              @order.seller = @order.list.seller
              @order.buyer = current_user
            end

            Order.transaction do
              if @order.list.buy_list?
                @order.payment_method = create_or_update_payment_method
              else
                order_payment_method = @order.list.payment_method.dup
                order_payment_method = order_payment_method.becomes!(OrderPaymentMethod)
                @order.payment_method = order_payment_method
              end
              if @order.save
                NotificationWorker.perform_async(NotificationWorker::NEW_ORDER, @order.id)
                render json: @order, serializer: OrderSerializer, status: :ok, root: 'data'
              else
                render json: { data: { message: 'Order not created', errors: @order.errors }}, status: :ok
              end
            end
          end
        end
      end

      def show
        @order = Order.from_user(current_user.address).find_by(uuid: params[:id])
        render json: @order, serializer: OrderSerializer, include: "**", status: :ok, root: 'data'
      end

      def cancel
        @order = Order.from_user(current_user.address).find_by(uuid: params[:id])
        @order.cancel(current_user)

        @order.broadcast

        render json: @order, serializer: OrderSerializer, include: "**", status: :ok, root: 'data'
      end

      protected

      def order_params
        params.require(:order).permit(:fiat_amount, :token_amount, :price, :list_id)
      end


      def payment_method_params
        params.require(:order)
              .require(:payment_method).permit(:id, values: {})
      end

      def create_or_update_payment_method
        if payment_method_params[:id]
          @payment_method = OrderPaymentMethod.find(payment_method_params[:id])
          if (@payment_method.user == current_user)
            @payment_method.update(payment_method_params)
          end
        else
          @payment_method = OrderPaymentMethod.new(payment_method_params)
          @payment_method.user = current_user
          @payment_method.bank_id = @order.list.bank_id
          @payment_method.save
        end
        @payment_method
      end
    end
  end
end
