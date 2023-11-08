# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
      column do
        panel "Orders" do
          Order.group(:status).count.each do |k,v|
            para link_to "#{k}: #{v}", admin_orders_path(scope: k)
          end
        end
      end

      column do
        panel "Users Count" do
          para User.count
        end
      end

      column do
        panel "Lists Count" do
          para List.count
        end
      end
    end
  end # content
end
