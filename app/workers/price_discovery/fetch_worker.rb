module PriceDiscovery
  class FetchWorker
    include Sidekiq::Worker
    attr_accessor :page, :token, :fiat, :type
    PER_PAGE = 20

    def perform(token, fiat, type)
      @page = 1
      @token = token
      @fiat = fiat
      @type = type
      first_page = search

      results = []
      if first_page
        results << first_page.data.map { |ad| ad.dig('adv', 'price').to_f }
        total_pages = (first_page.total.to_f / PER_PAGE.to_f).ceil
        (2..total_pages).each do |page|
          @page = page
          page_result = search
          if page_result
            results << page_result.data.map { |ad| ad.dig('adv', 'price').to_f }
          else
            break
          end
        end
      end

      sorted = results.flatten.sort
      return unless sorted.length >= 3

      median = if sorted.length.odd?
        sorted[sorted.length / 2]
      else
        (sorted[sorted.length / 2] + sorted[sorted.length / 2 - 1]) / 2.0
      end

      Rails.cache.write("prices/#{token.upcase}/#{fiat.upcase}/#{type}",
                        [sorted.min, median, sorted.max], expires_in: 1.hour)
    end

    private

    def search
      response = RestClient.post(url, options, headers)
      return unless response.code == 200

      page_result = JSON.parse(response.body)
      if page_result && page_result['success']
        OpenStruct.new(page_result)
      end
    end

    def url
      'https://p2p.binance.com/bapi/c2c/v2/friendly/c2c/adv/search'
    end

    def options
      {
        page: page,
        rows: PER_PAGE,
        'publisherType': nil,
        asset: token,
        tradeType: type,
        fiat: fiat,
        payTypes: []
      }.to_json
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Content-Length" => options.size,
      }
    end
  end
end

