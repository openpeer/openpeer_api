module Biconomy
  class SetupContract
    attr_accessor :id, :address, :chain_id, :version

    def initialize(id, address, chain_id, version)
      @id = id
      @address = address
      @chain_id = chain_id
      @version = version
    end

    def execute
      RestClient.post(url, payload, headers)
    end

    private

    def url
      'https://api.biconomy.io/api/v1/smart-contract/public-api/addContract'
    end

    def abi
      File.read(Rails.root.join('config', 'abis', version, 'OpenPeerEscrow.json'))
    end

    def payload
      {
        'contractName' => "Seller Contract v#{version} #{id}",
        'contractAddress' => address,
        'abi' => abi,
        'contractType' => 'SC',
        'metaTransactionType' => 'TRUSTED_FORWARDER'
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
