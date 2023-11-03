require 'sidekiq-scheduler'

module PriceDiscovery
  class CoordinatorWorker
    include Sidekiq::Worker

    def perform
      Token.where(allow_binance_rates: true).pluck(:symbol).uniq.each do |token|
        FiatCurrency.where(allow_binance_rates: true).pluck(:code).uniq.each do |fiat|
          PriceDiscovery::FetchWorker.perform_async(token, fiat, 'BUY')
          PriceDiscovery::FetchWorker.perform_async(token, fiat, 'SELL')
        end
      end
    end
  end
end
