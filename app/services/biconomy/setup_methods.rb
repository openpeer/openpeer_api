module Biconomy
  class SetupMethods
    attr_accessor :id, :address, :chain_id

    def initialize(id, address, chain_id)
      @id = id
      @address = address
      @chain_id = chain_id
    end

    def execute
      %w(release buyerCancel sellerCancel markAsPaid openDispute resolveDispute).each do |method|
        RestClient.post(url, payload(method), headers)
      end
    end

    private

    def url
      'https://api.biconomy.io/api/v1/meta-api/public-api/addMethod'
    end

    def payload(method)
      {
        'apiType' => 'native',
        'methodType' => 'write',
        'name' => "#{method} Escrow #{id}",
        'contractAddress' => address,
        'method' => method
      }.to_json
    end

    def api_key
      ENV["BICONOMY_#{chain_id}_API_KEY"]
    end

    def headers
      {
        'accept' => 'application/json',
        'authToken' =>  ENV['BICONOMY_AUTH_TOKEN'],
        'apiKey' =>  api_key,
        'content-type' => 'application/json'
      }
    end
  end
end
