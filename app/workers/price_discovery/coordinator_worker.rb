require 'sidekiq-scheduler'

module PriceDiscovery
  class CoordinatorWorker
    include Sidekiq::Worker

    def perform
      Token.where(allow_binance_rates: true).pluck(:symbol).uniq.each do |token|
        FiatCurrency.where(allow_binance_rates: true).pluck(:code).uniq.each do |fiat|
          PriceDiscovery::FetchWorker.new.perform(token, fiat, 'BUY')
          PriceDiscovery::FetchWorker.new.perform(token, fiat, 'SELL')
        end
      end
    end
  end
end
