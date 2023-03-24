ActiveAdmin.register Token do
  form do |f|
    f.inputs do
      f.input :address
      f.input :decimals
      f.input :symbol
      f.input :name
      f.input :chain_id
      f.input :coingecko_id
      f.input :coinmarketcap_id
      f.input :gasless
    end
    f.actions
  end
end
