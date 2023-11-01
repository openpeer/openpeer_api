module Api
  module V1
    class OrdersController < JwtController
      def index
        chain_id_condition = { chain_id: params[:chain_id] } if params[:chain_id]
        @orders = Order.includes(:list).from_user(current_user.address)
                       .where(chain_id_condition)
        render json: @orders, each_serializer: OrderSerializer, include: '**', status: :ok, root: 'data'
      end

      def create
        @order = Order.new(order_params)

        if @order.list.accept_only_verified? && !current_user.verified?
          return render json: { data: { message: 'Order not created' }}, status: :ok
        end

        if @order.list.buy_list?
          @order.seller = current_user
          @order.buyer = @order.list.seller
        else
          @order.seller = @order.list.seller
          @order.buyer = current_user
        end

        Order.transaction do
          @order.payment_method = create_or_update_payment_method
          @order.chain_id = @order.list.chain_id
          @order.deposit_time_limit = @order.list.deposit_time_limit
          @order.payment_time_limit = @order.list.payment_time_limit
          if @order.save
            NotificationWorker.perform_async(NotificationWorker::NEW_ORDER, @order.id)
            if @order.deposit_time_limit.to_i > 0
              AutomaticCancellationWorker.perform_in(@order.deposit_time_limit.minutes,
                @order.id, AutomaticCancellationWorker::DEPOSIT)
            end
            render json: @order, serializer: OrderSerializer, status: :ok, root: 'data'
          else
            render json: { data: { message: 'Order not created', errors: @order.errors }}, status: :ok
          end
        end
      end

      def show
        @order = Order.from_user(current_user.address).find_by(uuid: params[:id])
        render json: @order, serializer: OrderSerializer, include: "**", status: :ok, root: 'data'
      end

      def cancel
        @order = Order.from_user(current_user.address).find_by(uuid: params[:id])

        Order.transaction do
          @order.cancel(current_user) if @order.can_cancel? && @order.simple_cancel?
          if params[:cancellation]
            reasons = []
            params[:cancellation].each do |key, value|
              if key == "other" && params[:other_reason]
                reasons << params[:other_reason]
              elsif value
                reasons << key
              end
            end
            if reasons.any?
              CancellationReason.create(reasons.map { |reason| { order: @order, reason: reason } })
            end
          end
        end

        @order.broadcast

        render json: @order, serializer: OrderSerializer, include: "**", status: :ok, root: 'data'
      end

      protected

      def order_params
        params.require(:order).permit(:fiat_amount, :token_amount, :price, :list_id)
      end


      def copy_payment_method_params
        params.require(:order)
              .require(:payment_method).permit(:id, :bank_id, values: {})
      end

      def new_payment_method_params
        params.require(:order)
              .require(:payment_method).permit(:bank_id, values: {})
      end

      def create_or_update_payment_method
        if copy_payment_method_params[:id]
          @payment_method = ListPaymentMethod.find(copy_payment_method_params[:id])
          order_payment_method = @payment_method.dup
          order_payment_method = order_payment_method.becomes!(OrderPaymentMethod)
          order_payment_method.save
          @payment_method = order_payment_method
        elsif new_payment_method_params[:bank_id]
          @payment_method = OrderPaymentMethod.new(new_payment_method_params)
          @payment_method.user = current_user
          @payment_method.save
        end
        @payment_method
      end
    end
  end
end
