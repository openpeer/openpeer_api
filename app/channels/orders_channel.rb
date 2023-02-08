class OrdersChannel < ApplicationCable::Channel
  def subscribed
    @order = Order.from_user(current_user.address).find_by(uuid: params[:order_id])
    stream_from @order
  end

  def unsubscribed
    stop_all_streams
  end
end
