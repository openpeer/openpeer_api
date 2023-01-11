FactoryBot.define do
  factory(:api_user) do
    name { Faker::Internet.name }
    token { Faker::Internet.password }
  end

  factory(:user, aliases: [:seller]) do
    address { Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed }
  end

  factory(:list) do
    seller
    token
    fiat_currency
    chain_id { 137 }
    total_available_amount { (1000 * 10**6).to_s } # token has 6 demails
    limit_min { (10 * 10**6).to_s }
    limit_max { (100 * 10**6).to_s }
    margin_type { List.margin_types[:fixed] }
    margin { 1.1 }
    terms { Faker::Movie.quote }
    payment_method
  end

  factory(:token) do
    chain_id { 137 }
    address { Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed }
    decimals { 6 }
    symbol { 'USDT' }
    name { 'USDT' }
    coingecko_id { 'tether' }
  end

  factory(:fiat_currency) do
    code { 'BRL'}
    name { 'Brazilian Real' }
    country_code { 'br' }
  end

  factory(:bank) do
    name { 'PIX' }
  end

  factory(:payment_method) do
    user
    bank
    account_name { Faker::Name.name_with_middle }
    account_number { Faker::Bank.account_number }
    details { "IBAN #{Faker::Bank.iban}"}
  end
end
