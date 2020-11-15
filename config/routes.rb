require "sidekiq/web"
Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
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
  # post "/graphql", to: "graphql#execute"
  post "resend/create", to: "resend#create"
  get "users/edit_invite", to: "users#edit_invite"
  post "users/accepte_invite", to: "users#accepte_invite"
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
        patch :extend_deadline
        patch :create_response_round
        post :invite_respondents
        get :edit_hindi_summary
        get :edit_english_summary
        patch :update_response_submission_message
        get :show_response_submission_message
      end
      collection do
        get :export_as_excel
        patch "/page_component/:id", to: "consultations#page_component", as: "page_component"
        patch "/hindi_page_component/:id", to: "consultations#hindi_page_component", as: "hindi_page_component"
      end
      resources :questions
    end
    resources :ministries do
      member do
        post :approve
        post :reject
      end
    end
    resources :case_studies
    resources :categories
    resources :organisations do
      member do
        get :list_employees, controller: 'employees'
        post :invite, controller: 'employees'
        delete "deactivate/:user_id", to: "employees#deactivate", as: "deactivate"
      end
    end
  end

  namespace :organisation do
    resources :consultations do
      member do
        post :publish
        patch :extend_deadline
        patch :create_response_round
        post :invite_respondents
        get :edit_hindi_summary
        get :edit_english_summary
      end
      collection do
        patch "/page_component/:id", to: "consultations#page_component", as: "page_component"
        patch "/hindi_page_component/:id", to: "consultations#hindi_page_component", as: "hindi_page_component"
      end
      resources :questions
    end
    resources :settings do
      member do
        get :list_employees, controller: 'employees'
        get "/details/:user_id", to: "employees#details", as: "employee_details"
        patch "/edit_employee/:user_id", to: "employees#edit_employee", as: "edit_employee"
        post :invite, controller: 'employees'
        delete "deactivate/:user_id", to: "employees#deactivate", as: "deactivate"
        get :list_respondents
        delete "respondents/:user_id", to: "settings#destroy_respondents", as: "destroy_respondents"
      end
    end
  end
end
