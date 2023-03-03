class OrdersChannel < ApplicationCable::Channel
  def subscribed
    @order = Order.from_user(current_user.address).find_by(uuid: params[:order_id])
    return reject_subscription unless @order

    stream_from "OrdersChannel_#{@order.uuid}_#{current_user.address}"
  end

  def unsubscribed
    stop_all_streams
  end
end
