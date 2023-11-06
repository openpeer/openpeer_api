module Api
  module V1
    class PricesController < BaseController
      def show
        @prices = Rails.cache.fetch(cache_key) || []
        render json: @prices[price_source_index], status: :ok
      end

      private

      def price_source_index
        {
          'binance_min' => 0,
          'binance_median' => 1,
          'binance_max' => 2,
          'coingecko' => 4,
        }.fetch(params[:price_source], 4)
      end

      def cache_key
        "prices/#{params[:token].upcase}/#{params[:fiat].upcase}/#{params[:type].upcase}"
      end
    end
  end
end
