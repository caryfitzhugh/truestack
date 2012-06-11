Truestack::Application.routes.draw do
  resources :subscriptions

  match "/director" => "director#index"
  constraints(:subdomain => 'director') do
    match "/" => "director#index"
  end

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' }

  get "about" => "static#about"

  authenticated :user do
    root to: 'user_applications#index'
  end

  get 'bootstrap/base-css' => 'static#base_css'
  get 'bootstrap/scaffolding' => 'static#scaffolding'
  get 'bootstrap/components' => 'static#components'

  get  "signups/thanks" => "signups#thanks"
  post "signups" => "signups#create"
  get  "signups" => "signups#new"

  resources :user_applications, :path => "apps" , :as => "apps" do
    post :reset_token
    post :purge_data
  end

  post  "/app/startup"           => "user_application_fallback#create_startup_event"
  post  "/app/metric"            => "user_application_fallback#create_metric_event"
  post  "/app/exception"         => "user_application_fallback#create_exception_event"
  get   "/app/browser"           => "user_application_fallback#create_browser_event"

  match "/app/request"           => "user_application_fallback#create_request_event"

  resource "admin", :only => [:show] do
    resources :collector_workers
  end

  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'

  root to: 'signups#new'
end
