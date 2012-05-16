Truestack::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' }

  get "about" => "static#about"

  authenticated :user do
    root to: 'user_applications#index'
  end

  get 'bootstrap/base-css' => 'static#base_css'
  get 'bootstrap/scaffolding' => 'static#scaffolding'
  get 'bootstrap/components' => 'static#components'
  root to: 'signups#new'

  get  "signups/thanks" => "signups#thanks"
  post "signups" => "signups#create"
  get  "signups" => "signups#new"

  resources :user_applications, :path => "apps"

  post  "/app/startup"           => "user_applications#create_startup_event"
  post  "/app/metric"            => "user_applications#create_metric_event"
  post  "/app/exception"         => "user_applications#create_exception_event"

  get   "/app/browser"           => "user_applications#create_browser_event"
  get   "/app/browser_event"     => "user_applications#create_browser_event"

  match "/app/request"           => "user_applications#create_request_event"

  match "/director" => "director#index"

  resources :collector_workers

# DEBUG
  post "debug/create_deployment_data/:id" => 'deployments#debug_create_data', as: 'debug_create_deployment_data'
end
