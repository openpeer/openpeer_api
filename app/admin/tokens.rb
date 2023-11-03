ActiveAdmin.register Token do
  permit_params :address, :decimals, :symbol, :name, :position, :chain_id, :coingecko_id, :coinmarketcap_id, :gasless,
                :minimum_amount, :allow_binance_rates
  form do |f|
    f.inputs do
      f.input :address
      f.input :decimals
      f.input :symbol
      f.input :name
      f.input :position
      f.input :chain_id
      f.input :coingecko_id
      f.input :coinmarketcap_id
      f.input :minimum_amount
      f.input :gasless
      f.input :allow_binance_rates
    end
    f.actions
  end
end
