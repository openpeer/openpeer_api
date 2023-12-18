require 'sidekiq-scheduler'

module Airdrop
  class CoordinatorWorker
    include Sidekiq::Worker

    def perform
      Contract.where('version::integer = ?', Setting['contract_version'])
              .where.not(chain_id: List::TRON_CHAIN_IDS).pluck(:id).each do |contract_id|
        Airdrop::PointsWorker.perform_async(contract_id, Time.now.utc.to_i)
      end
    end
  end
end
