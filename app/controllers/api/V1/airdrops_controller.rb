module Api
  module V1
    class AirdropsController < BaseController
      def index
        @user = User.find_or_create_by_address(airdrop_params[:address]) rescue nil
        return render json: { message: 'Invalid address' }, status: :not_found unless @user

        @user_volume = user_volume_query(@user)
        @total_volume = total_volume_query

        render json: @user_volume.merge({ total: @total_volume }), status: :ok
      end

      private

      def date_range
        start_date = Date.new(2023, 6, 1)
        end_date = Date.new(2024, 7, 1)
        [start_date.beginning_of_day, end_date.end_of_day]
      end

      def airdrop_params
        params.permit(:address, :round)
      end

      def user_volume_query(user)
        orders = user.orders.joins(list: :token).left_joins(:dispute).closed
                            .where(disputes: { id: nil })
                            .where('orders.created_at >= ? AND orders.created_at <= ?', *date_range)
        buy_volume = 0
        sell_volume = 0
        orders.inject(0) do |sum, order|
          if order.buyer_id == user.id
            buy_volume += (order.token_amount * order.list.token.price_in_currency('USD'))
          else
            sell_volume += (order.token_amount * order.list.token.price_in_currency('USD'))
          end
        end
        { buy_volume: buy_volume, sell_volume: sell_volume, points: user.orders.sum(:points),
          liquidity_points: user.contracts.sum(:points) }
      end

      def total_volume_query
        orders = Order.joins(list: :token).left_joins(:dispute).closed
                      .where(disputes: { id: nil })
                      .where('orders.created_at >= ? AND orders.created_at <= ?', *date_range)

        orders.inject(0) do |sum, order|
          sum + (order.token_amount * order.list.token.price_in_currency('USD'))
        end
      end
    end
  end
end
