class MoralisStreamWebhookUpdater
  attr_accessor :host_url

  def initialize(host_url)
    @host_url = host_url
  end

  def execute
    response = RestClient.post(deployer_url, deployer_payload, headers)
    if response.code == 200
      puts RestClient.post(escrows_url, escrows_payload, headers).code
    else
      puts "First request failed with status code #{response.code}"
    end
  end

  private

  def deployer_url
    "https://api.moralis-streams.com/streams/evm/#{ENV['DEPLOYER_STREAM_ID']}"
  end

  def escrows_url
    "https://api.moralis-streams.com/streams/evm/#{ENV['ESCROW_EVENTS_STREAM_ID']}"
  end

  def deployer_payload
    {'webhookUrl' => api_webhooks_url(host: host_url) }.to_json
  end

  def escrows_payload
    {'webhookUrl' => api_webhooks_escrows_url(host: host_url) }.to_json
  end

  def headers
    {
      'accept' => 'application/json',
      'X-API-Key' => ENV['MORALIS_API_KEY'],
      'content-type' => 'application/json'
    }
  end
end
