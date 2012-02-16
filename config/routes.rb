Truestack::Application.routes.draw do
  root :to => "dashboard#show"

  get "dashboard" => 'dashboard#show'

  resources :application_actions, :only=>[:create]
  resources :deployments, :only=>[:create]

  resources :access_tokens

  match "/director" => "director#index"

  resources :collector_workers
end
