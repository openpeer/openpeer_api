# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


currency = FiatCurrency.create(name: 'Brazilian Real', code: 'BRL')
FiatCurrency.create(name: 'Australian Dollar', code: 'AUD')
FiatCurrency.create(name: 'Indian Ruppee', code: 'INR')

token = Token.create(chain_id: 80001, address: Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed,
                     decimals: 18, name: 'USDT', symbol: 'USDT', coingecko_id: 'tether')

seller = User.create(address: Eth::Address.new(Faker::Blockchain::Ethereum.address).checksummed)
List.create!(chain_id: 80001, seller: seller, 
             token: token ,
             fiat_currency: currency,
             total_available_amount: "1000000000",
             limit_min: 100,
             limit_max: 500,
             margin: 1.05)