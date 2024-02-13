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
      # @TODO: change this to the correct url
      'https://3469-2001-8a0-7296-db00-3869-8431-dce6-2eb6.ngrok-free.app/api/blast'
    end

    def webhook_url
      Blast::ESCROW_EVENTS.include?(event) ? "#{base_url}/webhooks/escrows" : "#{base_url}/webhooks"
    end
  end
end
