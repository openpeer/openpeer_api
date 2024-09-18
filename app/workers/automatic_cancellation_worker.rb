class AutomaticCancellationWorker
  include Sidekiq::Worker

  DEPOSIT = 'deposit'.freeze

  def perform(order_id, type)
    order = Order.find(order_id)

    return if order.cancelled? # Idempotency check

    if type == DEPOSIT
      limit = order.deposit_time_limit.to_i
      return unless limit > 0 && Time.zone.now >= order.created_at + limit.minutes &&
        order.can_cancel? && order.simple_cancel?

      Order.transaction do
        order.lock! # Lock the order to prevent race conditions
        order.cancel(order.seller)
      end
    end
    order.broadcast
  end
end