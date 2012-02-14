Truestack::Application.routes.draw do
  resources :deployments

  resources :access_tokens

  match "/director" => "director#index"

  resources :collector_workers
end
