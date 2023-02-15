Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  namespace 'api' do
    namespace 'v1' do
      resources :lists, only: [:index, :create, :show]
      resources :tokens, only: [:index]
      resources :currencies, only: [:index]
      resources :banks, only: [:index]
      resources :payment_methods, only: [:index]
      resources :orders, only: [:index, :create, :show]
      resources :users, only: [:show]
      resources :user_profiles, only: [:show, :update]
    end

    get "/webhooks", to: "webhooks#index"
    post "/webhooks", to: "webhooks#create"
    post "/webhooks/escrows", to: "webhooks#escrows"
  end
end
