require "sidekiq/web"
Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?
  mount ImageUploader.derivation_endpoint => "/derivations/image"
  mount CmPageBuilder::Rails::Engine => "/cm_page_builder"

  devise_for :users, controllers: {sessions: "sessions"}
  devise_scope :user do
    root to: "devise/sessions#new"
  end
  mount SpotlightSearch::Engine => "/spotlight_search"
  mount Sidekiq::Web => "/sidekiq"
  get "signin_google","signin_linkedin","signin_facebook", to: "oauth#redirect_to_provider"
  get "users/auth/:provider/callback", to: "oauth#callback"
  get "users/auth/failure" => "oauth#failure"
  post "/graphql", to: "graphql#execute"
  post "resend/create", to: "resend#create"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :admin do
    resources :users do
      collection do
        get :export_as_excel
      end
    end
    resources :consultations do
      member do
        post :publish
        post :reject
        post :featured
        post :unfeatured
        get :check_active_ministry
        get :edit_hindi_summary
      end
      collection do
        get :export_as_excel
        patch "/page_component/:id", to: "consultations#page_component", as: "page_component"
        patch "/hindi_page_component/:id", to: "consultations#hindi_page_component", as: "hindi_page_component"
      end
    end
    resources :ministries do
      member do
        post :approve
        post :reject
      end
    end
    resources :case_studies
    resources :categories
  end
end
