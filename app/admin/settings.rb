ActiveAdmin.register Setting do
  permit_params :name, :value, :description
end
