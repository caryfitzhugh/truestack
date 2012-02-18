Truestack::Application.routes.draw do
  resources :user_applications, :only => [:index, :show], :path => "apps"

  root :to => "user_applications#index"

  resources :application_actions, :only=>[:create]

  resources :deployments, :only=>[:create, :show]

  resources :access_tokens

  match "/director" => "director#index"

  resources :collector_workers

# DEBUG
  post "debug/create_deployment_data/:id" => 'deployments#debug_create_data', :as => 'debug_create_deployment_data'
end
