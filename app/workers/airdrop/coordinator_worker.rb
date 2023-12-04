require 'sidekiq-scheduler'

module Airdrop
  class CoordinatorWorker
    include Sidekiq::Worker

    def perform
      Contract.where('version::integer = ?',  Setting['contract_version']).pluck(:id) do |contract_id|
        Airdrop::PointsWorker.perform_async(contract_id, Time.now.utc.to_i)
      end
    end
  end
end
