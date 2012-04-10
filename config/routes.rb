Truestack::Application.routes.draw do
  devise_for :users

  get "about" => "static#about"
  root :to => "static#home"

  resources :user_applications, :path => "apps"

  get   "/app/browser_event"     => "user_applications#create_browser_event"
  match "/app/request"           => "user_applications#create_request_event"
  post "/app/event"     => "user_applications#create_event"

  resources :deployments, :only=>[:create, :show], :path => "app/deployments"

  match "/director" => "director#index"

  resources :collector_workers

# DEBUG
  post "debug/create_deployment_data/:id" => 'deployments#debug_create_data', :as => 'debug_create_deployment_data'
end
