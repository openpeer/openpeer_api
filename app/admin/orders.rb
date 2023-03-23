ActiveAdmin.register Order do
  menu priority: 4
  actions :index, :show

  scope :all, default: true
  scope :created, group: :status
  scope :escrowed, group: :status
  scope :release, group: :status
  scope :cancelled, group: :status
  scope :dispute, group: :status
  scope :closed, group: :status

  includes :list

  index do
    column :uuid
    column ("List") { |order| link_to(order.list.id, admin_list_path(order.list), target: '_blank') }
    column :buyer
    column :token_amount do |order|
      link_to("#{order.token_amount} #{order.list.token.symbol}", admin_token_path(order.list.token))
    end
    column :fiat_amount do |order|
      link_to("#{order.list.fiat_currency.symbol} #{order.fiat_amount}", admin_fiat_currency_path(order.list.fiat_currency))
    end
    column ("Status") { |order| status_tag order.status }
    column ("Price") do |order|
      "#{order.list.fiat_currency.symbol} #{order.price} per #{order.list.token.symbol}"
    end
    column :created_at
    actions
  end

  show do
    render partial: "admin/orders/attributes_table", locals: { order: order }
  end
end
