class AirdropData
  attr_accessor :round
  POINTS = 1_000_000

  def initialize(round)
    @round = round
  end

  def process
    orders.find_each do |order|
      usd_value = order.token_amount * order.list.token.price_in_currency('USD')
      points = (usd_value.to_f / total_volume.to_f) * POINTS
      order.update(points: points.to_f / 2.0)
    end
  end

  private

  def total_volume
    @total_volume ||= orders.inject(0) do |sum, order|
      sum + (order.token_amount * order.list.token.price_in_currency('USD'))
    end
  end
  
  def round_to_time_window
    start_date = Date.new(2023, 6, 1) + (round - 1).months
    end_date = start_date.end_of_month
    [start_date.beginning_of_day, end_date.end_of_day]
  end

  def orders
    @orders ||= Order.joins(list: :token).left_joins(:dispute).closed.where(disputes: { id: nil })
                     .where('orders.created_at >= ? AND orders.created_at <= ?', *round_to_time_window)
  end
end