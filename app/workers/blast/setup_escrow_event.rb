module Blast
  class SetupEscrowEvent
    include Sidekiq::Worker

    def perform(contract, chain_id, event)
      Blast::SetupWebhook.new(contract, chain_id, event).execute
    end
  end
end
