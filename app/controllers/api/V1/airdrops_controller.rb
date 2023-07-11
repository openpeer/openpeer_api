module Api
  module V1
    class AirdropsController < BaseController
      def index
        @user = User.find_or_create_by_address(airdrop_params[:address]) rescue nil
        return render json: { message: 'Invalid address' }, status: :not_found unless @user

        round = [1, airdrop_params[:round].to_i].max

        @user_volume = user_volume_query(@user, round)
        @total_volume = total_volume_query(round)

        render json: @user_volume.merge({ total: @total_volume }), status: :ok
      end

      private

      # returns the time window for a given round. every month is a round starting in June 2023
      # round 1 is June 1st 2023 to the last day of June, round 2 is July 1st 2023 to the last day of July, etc.

      def round_to_time_window(round)
        start_date = Date.new(2023, 6, 1) + (round - 1).months
        end_date = start_date.end_of_month
        [start_date, end_date]
      end

      def airdrop_params
        params.permit(:address, :round)
      end

      def user_volume_query(user, round)
        orders = user.orders.joins(list: :token).left_joins(:dispute).closed
                            .where(lists: { tokens: { symbol: tokens }})
                            .where(disputes: { id: nil })
                            .where('orders.created_at >= ? AND orders.created_at <= ?', *round_to_time_window(round))
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

      def total_volume_query(round)
        orders = Order.joins(list: :token).left_joins(:dispute).closed
                      .where(lists: { tokens: { symbol: tokens }})
                      .where(disputes: { id: nil })
                      .where('orders.created_at >= ? AND orders.created_at <= ?', *round_to_time_window(round))

        orders.inject(0) do |sum, order|
          sum + (order.token_amount * order.list.token.price_in_currency('USD'))
        end
      end

      def tokens
        ['USDC', 'USDT', 'MATIC', 'ETH']
      end
    end
  end
end
