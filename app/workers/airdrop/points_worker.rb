require 'eth'

module Airdrop
  class PointsWorker
    include Sidekiq::Worker
    attr_accessor :contract
    POINTS_PER_USD = 0.000832

    def perform(contract_id, time = Time.now.utc.to_i)
      @contract = Contract.find(contract_id)
      
      values = Token.where(chain_id: contract.chain_id).map do |token|
        token_contract = Eth::Contract.from_abi(abi: abi, address: token.address, name: token.name)
        balance = client.call(token_contract, 'balanceOf', contract.address)
        usd_value = (balance.to_f / 10 ** token.decimals) * token.price_in_currency('USD')
        points = POINTS_PER_USD * usd_value
        contract.update(points: (contract.points || 0) + points)
        usd_value
      end

      contract.update(locked_value: values.compact.sum)
    end

    private

    def abi
      @abi ||= File.read(Rails.root.join('config', 'abis', 'erc20.json'))
    end

    def client
      @client ||= Eth::Client.create(ENV["NODE_URL_#{contract.chain_id}"])
    end
  end
end