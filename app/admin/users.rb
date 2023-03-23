ActiveAdmin.register User do
  menu priority: 3
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :address, :email, :name, :twitter, :image, :verified
  #
  # or
  #
  # permit_params do
  #   permitted = [:address, :email, :name, :twitter, :image, :verified]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
