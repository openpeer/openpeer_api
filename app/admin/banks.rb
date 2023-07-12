ActiveAdmin.register Bank do
  permit_params :name, :account_info_schema, fiat_currency_ids: []
  json_editor

  form do |f|
    f.inputs do
      f.input :name
      f.input :account_info_schema, as: :json
      f.input :fiat_currencies, :as => :check_boxes
    end
    f.actions
  end

  index do
    id_column
    column :name
    column :account_info_schema
    column :fiat_currencies do |bank|
      bank.fiat_currencies.pluck(:code).join(', ')
    end
    column :created_at
    column :updated_at
  end

  show do
    attributes_table do
      row :id
      row :name
      row :account_info_schema
      row :created_at
      row :updated_at
      table_for bank.fiat_currencies do
        column "Fiat Currencies" do |fiat_currency|
          link_to fiat_currency.name, [ :admin, fiat_currency ]
        end
      end
    end
  end
end
