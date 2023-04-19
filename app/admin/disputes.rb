ActiveAdmin.register Dispute do
  menu priority: 2
  actions :index, :show

  scope :active, group: :resolved, default: true
  scope :resolved, group: :resolved

  includes(:order, :winner, user_disputes: [:user, :dispute_files])

  member_action :resolve, method: :get, if: proc{ current_admin_user.admin? } do
    @dispute = resource
    if @dispute.resolved?
      flash[:error] = 'Error: This dispute is resolved.'
      return admin_dispute_path(resource)
    end
    @list = resource.order.list
    @escrow = resource.order.escrow.address
    buyer = resource.order.buyer
    seller = resource.order.seller
    @options = [["Buyer: #{buyer.address}", buyer.address], ["Seller: #{seller.address}", seller.address]]
  end

  action_item :view, only: :show,  if: proc{ current_admin_user.admin? } do
    link_to 'Resolve Dispute', resolve_admin_dispute_path(dispute) unless dispute.resolved?
  end

  index do
    column :id
    column ("Order") { |dispute| link_to(dispute.order.uuid, admin_order_path(dispute.order)) }
    column :resolved
    column ("Winner") { |dispute| link_to(dispute.winner.address, admin_user_path(dispute.winner)) if dispute.winner }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :resolved
      row ("Order") do
        render partial: "admin/orders/attributes_table", locals: { order: dispute.order }
      end
      row ("Winner") { |dispute| link_to(dispute.winner.address, admin_user_path(dispute.winner)) if dispute.winner }
      dispute.user_disputes.each do |user_dispute|
        label = dispute.order.buyer.id == user_dispute.user.id ? 'Buyer' : 'Seller'
        row "#{label} Evidence" do
          attributes_table_for user_dispute do
            row ("User") { link_to(user_dispute.user.address, admin_user_path(user_dispute.user), target: "_blank") }
            row :comments
            row :created_at
            row "Files" do
              div(style: "display: flex") do
                user_dispute.dispute_files.each do |file|
                  div(style: "margin-right: 5px") do
                    if (file.filename.ends_with?('.pdf'))
                      link_to(file.filename.split('/').last, file.upload_url, target: "_blank")
                    else
                      link_to(image_tag(file.upload_url, width: 100, height: 100), file.upload_url, target: "_blank")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
