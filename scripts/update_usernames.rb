require 'securerandom'
require 'set'
require_relative '../config/environment'

MAX_USERNAME_LENGTH = 15
MAX_DIGITS = 5

# Check for dry run mode
DRY_RUN = ARGV.include?('--dry-run')

# Combine and prepare the word list
WORDS = (
  %w[
    Airdrop Altcoin ASIC Attestation BeaconChain Bitcoin Block Blockchain Bounty BrainWallet Bridge BUIDL Bytecode Byzantine Coin ColdWallet Consensus Crypto DAO Dapp Decentralized DEX Defi DigitalAsset Ethereum Faucet Fiat Fork Gas Genesis Gwei Halving HardFork HardwareWallet Hash HDWallet Hexadecimal Hodl HotWallet Hyperledger ICO IPFS Layer2 Ledger LightClient Liquidity Mainnet MarketCap MEV MetaMask Mining Mnemonic Multisig NFT Nft Node Nonce Oracle P2P Parity Peer Plasma PoS PoW Protocol PublicKey Relayer Rollup RPC Satoshi Scalability Sharding Shiba Sidechain SmartContract Solana Solidity Stablecoin Staking Swap Testnet Tether Token TVL Validator Wallet Web3 Yield ZKP
  ] +
  %w[
    Aardvark Bear Cheetah Dolphin Elephant Fox Giraffe Hippo Iguana Jaguar Koala Lion Monkey Narwhal Otter Penguin Quokka Rhino Sloth Tiger Unicorn Vulture Walrus Xenops Yak Zebra Alligator Bison Camel Dingo Emu Flamingo Gazelle Hedgehog Ibex Jellyfish Kangaroo Lemur Meerkat Newt Ocelot Panda Quail Raccoon Seahorse Tapir Uakari Vole Wombat Xerus Yabby Zebu Alpaca Baboon Capybara Dugong Echidna Ferret Gorilla Hummingbird Impala Jackal Kiwi Lynx Manatee Numbat Okapi Platypus Quetzal Reindeer Skunk Toucan Uguisu Vicuna Wolverine Xlsma Yapok Zorse Anteater Bonobo Chameleon Dodo Elk Fossa Gibbon Hyena Ibis Jerboa Kookaburra Llama Mongoose Nightingale Orangutan Pangolin Quoll Rhinoceros Sloth Tamarin Urutu Viper Weasel Xenopus Yellowjacket Zorilla
  ]
).map(&:capitalize).uniq.select { |word| word.length <= (MAX_USERNAME_LENGTH - 1) }  # Ensure each word allows at least 1 digit

# Method to generate a random username
def generate_random_username
  word = WORDS.sample
  max_digits = [MAX_DIGITS, MAX_USERNAME_LENGTH - word.length].min
  digits = SecureRandom.random_number(10**max_digits).to_s.rjust(1, '0')
  "#{word}#{digits}"
end

# Method to generate a large number of unique usernames
def generate_unique_usernames(count)
  usernames = Set.new
  while usernames.size < count
    usernames.add(generate_random_username)
  end
  usernames.to_a
end

# Generate 10,000 unique usernames
unique_usernames = generate_unique_usernames(10_000)
$username_queue = unique_usernames.dup

# Method to get next unique username
def next_unique_username
  username = $username_queue.shift
  $username_queue.push(generate_random_username) if $username_queue.size < 1_000
  username
end

# Find users with null or empty name fields
users_to_update = User.where(name: [nil, '']).limit(6000)

# Update each user with a generated username
users_updated = 0
users_skipped = 0

puts "Running in #{DRY_RUN ? 'DRY RUN' : 'LIVE'} mode"

users_to_update.find_each do |user|
  max_attempts = 5
  attempts = 0

  begin
    attempts += 1
    new_username = next_unique_username

    if DRY_RUN
      puts "Would update user #{user.id} with username #{new_username}"
      users_updated += 1
    else
      user.update!(name: new_username)
      users_updated += 1
      puts "Updated user #{user.id} with username #{new_username}"
    end
  rescue ActiveRecord::RecordInvalid => e
    if attempts < max_attempts
      puts "Error updating user #{user.id}: #{e.message}. Retrying with a new username."
      retry
    else
      users_skipped += 1
      puts "Failed to update user #{user.id} after #{max_attempts} attempts. Skipping."
    end
  rescue ActiveRecord::RecordNotUnique => e
    if attempts < max_attempts
      puts "Duplicate username for user #{user.id}. Retrying with a new username."
      retry
    else
      users_skipped += 1
      puts "Failed to find a unique username for user #{user.id} after #{max_attempts} attempts. Skipping."
    end
  rescue StandardError => e
    users_skipped += 1
    puts "Unexpected error updating user #{user.id}: #{e.message}. Skipping."
  end
end

puts "Total users #{DRY_RUN ? 'would be' : ''} updated: #{users_updated}"
puts "Total users skipped: #{users_skipped}"
puts "Remaining unique usernames: #{$username_queue.size}"