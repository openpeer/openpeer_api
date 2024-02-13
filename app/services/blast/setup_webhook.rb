module Blast
  class SetupWebhook
    attr_accessor :contract, :chain_id, :event

    def initialize(contract, chain_id, event)
      @contract = contract
      @chain_id = chain_id
      @event = event
    end

    def execute
      RestClient.post(url, payload, headers)
    end

    private

    def payload
      {
        'webhook' => {
          'chainId' => chain_id,
          'addressList' => contract,
          'event' => event,
          'url' => webhook_url,
          'confirmations' => 1
        }
      }.to_json
    end

    def headers
      {
        'accept' => 'application/json',
        'content-type' => 'application/json',
        'Authorization' => "Bearer #{ENV['BLAST_WEBHOOKS_API_KEY']}"
      }
    end

    def url
      'https://events.openpeer.xyz/api/webhook'
    end

    def base_url
      'https://api.openpeer.xyz/api/blast'
    end

    def webhook_url
      Blast::ESCROW_EVENTS.include?(event) ? "#{base_url}/webhooks/escrows" : "#{base_url}/webhooks"
    end
  end
end
