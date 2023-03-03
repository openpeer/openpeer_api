require_relative './moralis_stream_webhook_updater'

namespace :deployer_contract do
  task :update_webhook, [:webhook_url] => :environment do |task, args|
    include Rails.application.routes.url_helpers
    webhook_url = args[:webhook_url]
    MoralisStreamWebhookUpdater.new(webhook_url).execute if webhook_url
  end

  task :update_contract, [:new_address, :abi_file] do |task, args|
    new_address = args[:new_address]
    abi_file = args[:abi_file]
  end
end
