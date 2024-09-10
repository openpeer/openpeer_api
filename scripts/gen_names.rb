require 'securerandom'
require 'set'

MAX_USERNAME_LENGTH = 15
MAX_DIGITS = 4

# Combine and prepare the word list
WORDS = (
  %w[
    Account Address Airdrop Altcoin ASIC Attestation BeaconChain Bitcoin Block Blockchain Bounty BrainWallet Bridge BUIDL Bytecode Byzantine Coin ColdWallet Consensus Crypto Cryptography DAO Dapp Decentralized DEX Defi DigitalAsset Ethereum Faucet Fiat Fork Gas Genesis Gwei Halving HardFork HardwareWallet Hash HDWallet Hexadecimal Hodl HotWallet Hyperledger ICO IPFS Layer2 Ledger LightClient Liquidity Mainnet MarketCap MEV MetaMask Mining Mnemonic Multisig NFT Nft Node Nonce Oracle P2P Parity Peer Plasma PoS PoW Protocol PublicKey Relayer Rollup RPC Satoshi Scalability Sharding Shiba Sidechain SmartContract Solana Solidity Stablecoin Staking Swap Testnet Tether Token TVL Validator Wallet Web3 Yield ZKP
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

# Generate and display 100 example usernames
puts "Generated 100 Example Usernames:"
puts "--------------------------------"

100.times do |i|
  username = generate_random_username
  puts "#{i + 1}. #{username}"
end

puts "--------------------------------"
puts "Total words available: #{WORDS.size}"
puts "Theoretical maximum combinations: #{WORDS.size * 10000}"  # 10000 because of up to 4 digits