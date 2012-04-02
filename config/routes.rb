Truestack::Application.routes.draw do
root :to => "user_applications#index"
  resources :user_applications, :only => [:index, :show], :path => "apps"
  post "/app/event"     => "user_applications#create_event"

  resources :deployments, :only=>[:create, :show], :path => "app/deployments"

  resources :access_tokens

  match "/director" => "director#index"

  resources :collector_workers

# DEBUG
  post "debug/create_deployment_data/:id" => 'deployments#debug_create_data', :as => 'debug_create_deployment_data'
end
