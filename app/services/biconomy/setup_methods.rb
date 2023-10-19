module Biconomy
  class SetupMethods
    attr_accessor :id, :address, :chain_id, :version

    def initialize(id, address, chain_id, version)
      @id = id
      @address = address
      @chain_id = chain_id
      @version = version
    end

    def execute
      methods[version].each do |method|
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
        'name' => "#{method} Seller Contract v2 #{id}",
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

    def methods
      {
        '1' => %w(release buyerCancel sellerCancel markAsPaid createERC20Escrow),
        '2' => %w(release buyerCancel sellerCancel markAsPaid createERC20Escrow deposit withdrawBalance)
      }
    end
  end
end
