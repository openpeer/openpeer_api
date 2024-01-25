require 'digest'
require 'sidekiq-scheduler'

module Tron
  class NewEscrowEventWorker
    TRACKING_CHAIN_ID = 999999992 # Tron Nile @TODO: change to mainnet
    include Sidekiq::Worker

    def perform
      # timestamp = (Time.now.to_i - 30) * 1000
      contracts.find_each do |contract|
        url = "#{chains[contract.chain_id].url}/v1/contracts/#{contract.address}/events" # ?event_name=EscrowCreated" # &min_block_timestamp=#{timestamp}"
        response = RestClient.get(url, headers = headers)
        puts response
        next unless response.code == 200
        json = JSON.parse(response.body)
        data = json.fetch('data', [])
        next unless data.any?

        puts data
      end
    end

    private

    def contracts
      @contracts ||= Contract.where(chain_id: TRACKING_CHAIN_ID,
                                    version: Setting['contract_version'] || '1')
    end

    def chains
      {
        999999992 => OpenStruct.new({ url: 'https://nile.trongrid.io' })
      }
    end
  end
end
