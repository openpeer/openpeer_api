class AutomaticCancellationWorker
  include Sidekiq::Worker

  DEPOSIT = 'deposit'.freeze
  PAYMENT = 'payment'.freeze

  def perform(order_id, type)
    order = Order.find(order_id)

    if type == DEPOSIT
      limit = order.deposit_time_limit.to_i
      return unless limit > 0 && Time.zone.now >= order.created_at + limit.minutes &&
        order.can_cancel? && order.simple_cancel?

      order.cancel(order.seller)
    end

    if type == PAYMENT
      # limit = order.payment_time_limit.to_i
      # return unless limit > 0 && Time.zone.now >= order.escrow.created_at + limit.minutes &&
      #   order.can_cancel? && order.simple_cancel?

      # order.cancel(order.buyer)
    end
    order.broadcast
  end
end
