Truestack::Application.routes.draw do
  resources :application_actions, :only=>[:create]
  resources :deployments, :only=>[:create]

  resources :access_tokens

  match "/director" => "director#index"

  resources :collector_workers
end
