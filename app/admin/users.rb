ActiveAdmin.register User do
  menu priority: 3
  actions :index, :show, :edit, :update
  permit_params :merchant, :name, :twitter, :verified, :imported_orders_count, :telegram_user_id, :telegram_username, :whatsapp_country_code, :whatsapp_number

  show do
    attributes_table do
      row :address
      row :name
      row :email
      row :twitter
      row :telegram_user_id
      row :telegram_username
      row :whatsapp_country_code
      row :whatsapp_number
      row :verified
      row :merchant
      row :image
      row :imported_orders_count
      row :created_at
      row :updated_at
      row ('Contracts') do |user|
        user.contracts.order(created_at: :desc).find_each do |contract|
          attributes_table_for contract do
            row :id
            row ('address') { |contract| link_to(contract.address, contract.link, target: '_blank')  }
            row ('chain') { |contract| contract.network_name }
            row :version
            row :created_at
          end
        end
      end
      row ('Payment Methods') do |user|
        user.list_payment_methods.find_each do |payment_method|
          attributes_table_for payment_method do
            row :id
            row :bank
            row :values
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs
    f.input :imported_orders_count
    f.actions
  end
end
