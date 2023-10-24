ActiveAdmin.register User do
  menu priority: 3
  actions :index, :show, :edit, :update
  permit_params :merchant, :name, :twitter
end
