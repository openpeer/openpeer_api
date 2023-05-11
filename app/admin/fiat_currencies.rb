ActiveAdmin.register FiatCurrency do
  permit_params :code, :name, :symbol, :country_code, :position
end
