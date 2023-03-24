# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
      # column do
      #   panel "Recent Lists" do
      #     ul do
      #       List.recent(5).map do |list|
      #         li link_to(post.id, admin_post_path(post))
      #       end
      #     end
      #   end
      # end

      column do
        panel "Info" do
          para "Welcome to OpenPeer Admin."
        end
      end
    end
  end # content
end
