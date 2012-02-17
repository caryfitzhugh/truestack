Truestack::Application.routes.draw do
  resources :user_applications, :only => [:index, :show], :path => "apps"

  root :to => "user_applications#index"

  resources :application_actions, :only=>[:create]

  resources :deployments, :only=>[:create]

  resources :access_tokens

  match "/director" => "director#index"

  resources :collector_workers
end
