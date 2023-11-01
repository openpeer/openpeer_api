ActiveAdmin.register List do
  actions :index, :show, :edit, :update
  permit_params :status, :margin_type, :margin
end
