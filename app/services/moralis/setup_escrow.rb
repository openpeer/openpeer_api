module Moralis
  class SetupEscrow
    attr_accessor :address

    def initialize(address)
      @address = address
    end

    def execute
      RestClient.post(url, payload, headers)
    end

    private

    def url
      "https://api.moralis-streams.com/streams/evm/#{stream_id}/address"
    end

    def stream_id
      ENV['ESCROW_EVENTS_STREAM_ID']
    end

    def payload
      {'address' => address }.to_json
    end

    def headers
      {
        'accept' => 'application/json',
        'X-API-Key' => ENV['MORALIS_API_KEY'],
        'content-type' => 'application/json'
      }
    end
  end
end
