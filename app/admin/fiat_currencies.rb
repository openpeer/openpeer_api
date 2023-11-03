ActiveAdmin.register FiatCurrency do
  permit_params :code, :name, :symbol, :country_code, :position, :allow_binance_rates, :default_price_source
end
