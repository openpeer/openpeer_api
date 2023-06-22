Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount ActionCable.server => '/cable'
  namespace 'api' do
    namespace 'v1' do
      resources :lists, only: [:index, :show]
      resources :tokens, only: [:index]
      resources :currencies, only: [:index]
      resources :banks, only: [:index]
      resources :payment_methods, only: [:index]
      resources :orders, only: [:index, :create, :show] do
        patch :cancel, on: :member
        resources :disputes, only: [:create]
      end
      resources :users, only: [:show]
      resources :user_profiles, only: [:show, :update]
      resources :quick_buy, only: [:index]
      resources :list_management, only: [:create, :update, :destroy]
      get '/airdrop/:address/:round', to: 'airdrops#index'
    end

    get '/webhooks', to: 'webhooks#index'
    post '/webhooks', to: 'webhooks#create'
    post '/webhooks/escrows', to: 'webhooks#escrows'
  end
end
