Truestack::Application.routes.draw do
  resources :access_tokens

  match "/director" => "director#index"

  resources :collector_workers
end
