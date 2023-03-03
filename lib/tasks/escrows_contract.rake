require_relative './moralis_stream_contract_updater'

namespace :escrows_contract do
  task :update, [:abi_file] => :environment do |task, args|
    abi_file = args[:abi_file]

    if abi_file
      # MoralisStreamContractUpdater.new(ENV['ESCROW_EVENTS_STREAM_ID'], abi_file).execute
    end
  end
end
