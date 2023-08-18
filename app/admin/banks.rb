ActiveAdmin.register Bank do
  permit_params :name, :account_info_schema, :image, :color, fiat_currency_ids: []
  json_editor

  before_action do
    ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :color
      f.input :image, as: :file
      f.input :account_info_schema, as: :json
      f.input :fiat_currencies, :as => :check_boxes
    end
    f.actions
  end

  index do
    id_column
    column :name
    column :color
    column :account_info_schema
    column :fiat_currencies do |bank|
      bank.fiat_currencies.order(:code).pluck(:code).join(', ')
    end
    column :created_at
    column :updated_at
  end

  show do
    attributes_table do
      row :id
      row :name
      row :color
      row :account_info_schema
      row :image do |bank|
        link_to bank.image.filename.to_s, bank.image.url, target: :blank if bank.image.attached?
      end
      row :created_at
      row :updated_at
      table_for bank.fiat_currencies.order(:name) do
        column "Fiat Currencies" do |fiat_currency|
          link_to fiat_currency.name, [ :admin, fiat_currency ]
        end
      end
    end
  end
end
