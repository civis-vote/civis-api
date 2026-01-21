require 'sidekiq/web'

Rails.application.routes.draw do
  resources :orders, only: :create

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  devise_scope :user do
    post 'validate_email', to: 'users/sessions#validate_email'
    get 'sign_in_with_credentials', to: 'users/sessions#sign_in_with_credentials'
    get 'resend_otp', to: 'users/sessions#resend_otp'
    post 'validate_credentials', to: 'users/sessions#validate_credentials'
  end

  mount CmAdmin::Engine => '/cm_admin'

  authenticate :user, ->(u) { u.role?('admin') || u.role?('super_admin') } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'cm_admin/static#index'

  get 'signin_google', to: 'oauth#redirect_to_provider'
  get 'signin_linkedin', to: 'oauth#redirect_to_provider'
  get 'signin_facebook', to: 'oauth#redirect_to_provider'
  get 'users/auth/:provider/callback', to: 'oauth#callback'
  get 'users/auth/failure' => 'oauth#failure'
  post '/graphql', to: 'graphql#execute'
  post 'resend/create', to: 'resend#create'
  get 'users/edit_invite', to: 'users#edit_invite'
  post 'users/accepte_invite', to: 'users#accepte_invite'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
