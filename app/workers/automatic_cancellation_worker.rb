class AutomaticCancellationWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    limit = order.deposit_time_limit.to_i
    return unless limit > 0 && Time.zone.now >= order.created_at + limit.minutes &&
      order.can_cancel? && order.simple_cancel?

    order.cancel(order.seller)
    order.broadcast
  end
end
