FactoryBot.define do
  factory :setting do
    name { "MyString" }
    value { "MyText" }
    description { "MyText" }
  end

  factory :contract do
    user { nil }
    chain_id { 1 }
    address { "MyString" }
  end

  factory :transaction do
    order { nil }
    tx_hash { "0xb7e6c378f8f1a26650d1a3920c926268fb43b83fbdde44cba1fbc92b52d83442" }
  end

  factory :dispute_file do
    dispute { nil }
    user { nil }
    filename { "MyString" }
  end

  factory :dispute do
    order { nil }
    seller_comment { "MyText" }
    buyer_comment { "MyText" }
    resolved { false }
    winner { nil }
  end

  factory :escrow do
    order
    tx { '0xb7e6c378f8f1a26650d1a3920c926268fb43b83fbdde44cba1fbc92b52d83442' }
    address { Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed }
  end

  factory(:api_user) do
    name { Faker::Internet.name }
    token { Faker::Internet.password }
  end

  factory(:user, aliases: [:seller, :buyer]) do
    address { Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed }
    email { Faker::Internet.email }
  end

  factory(:list) do
    type { 'BuyList' }
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

  factory(:order) do
    list
    buyer
    fiat_amount { 1 }
    token_amount { 10**6 }
    price { 1 }
  end
end
