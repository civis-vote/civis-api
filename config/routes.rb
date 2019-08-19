Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  devise_for :users, controllers: {sessions: "sessions"}
  devise_scope :user do
    root to: "devise/sessions#new"
  end
  get 'signin_google','signin_linkedin','signin_facebook', to: 'oauth#redirect_to_provider'
  get 'users/auth/:provider/callback', to: 'oauth#callback'
  get 'users/auth/failure' => 'oauth#failure'
  post "/graphql", to: "graphql#execute"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :admin do
    resources :users
    resources :consultations
    resources :ministries do
      member do
        post :approve
        post :reject
      end
    end
  end
end
