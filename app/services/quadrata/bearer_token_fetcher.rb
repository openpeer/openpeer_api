class Quadrata::BearerTokenFetcher
  class << self
    def fetch
      response = RestClient::Request.execute(
        method: :post,
        url: url,
        verify_ssl:  false,
        headers: headers,
        payload: body
      )
      JSON.parse(response.body).dig('data', 'accessToken')
    end

    private

    def url
      "#{ENV['QUADRATA_API_URL']}/login"
    end

    def headers
      { 'Content-Type' => 'application/json' }
    end

    def body
      { 'apiKey' => ENV['QUADRATA_API_KEY'] }.to_json
    end
  end
end
