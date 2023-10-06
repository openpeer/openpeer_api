class AirdropData
  attr_accessor :round

  def initialize(round)
    @round = round
  end

  def report
    user_volume = {}
    report = {}

    User.where(id: users).find_each do |user|
      volume = user_volume_query(user)
      user_volume[user.address] = { buy_volume: volume[:buy_volume].to_s, sell_volume: volume[:sell_volume].to_s }
      report[user.address] = volume.values.sum.to_s
    end
    
    puts "Total volume: #{total.to_s}"
    [user_volume, report]
  end

  private

  def total_volume_query
    orders = Order.joins(list: :token).left_joins(:dispute).closed
                  .where(disputes: { id: nil })
                  .where('orders.created_at >= ? AND orders.created_at <= ?', *round_to_time_window)
  
    orders.inject(0) do |sum, order|
      sum + (order.token_amount * order.list.token.price_in_currency('USD'))
    end
  end
  
  def round_to_time_window
    start_date = Date.new(2023, 6, 1) + (round - 1).months
    end_date = start_date.end_of_month
    [start_date, end_date]
  end
  
  def user_volume_query(user)
    orders = user.orders.joins(list: :token).left_joins(:dispute).closed
                        .where(disputes: { id: nil })
                        .where('orders.created_at >= ? AND orders.created_at <= ?', *round_to_time_window)
    buy_volume = 0
    sell_volume = 0
    orders.inject(0) do |sum, order|
      if order.buyer_id == user.id
        buy_volume += (order.token_amount * order.list.token.price_in_currency('USD'))
      else
        sell_volume += (order.token_amount * order.list.token.price_in_currency('USD'))
      end
    end
    { buy_volume: buy_volume, sell_volume: sell_volume }
  end

  def orders
    @orders ||= Order.joins(list: :token).left_joins(:dispute).closed.where(disputes: { id: nil })
                     .where('orders.created_at >= ? AND orders.created_at <= ?', *round_to_time_window)
  end

  def sellers
    @sellers ||= orders.pluck(:seller_id)
  end

  def buyers
    @buyers ||= orders.pluck(:buyer_id)
  end

  def users
    @users ||= (sellers + buyers).uniq
  end

  def total
    @total ||= total_volume_query
  end
end