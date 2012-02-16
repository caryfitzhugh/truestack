Truestack::Application.routes.draw do
  resources :deployments, :only=>[:create]

  resources :access_tokens

  match "/director" => "director#index"
  post "/request"   => "collector_workers#ingest"

  resources :collector_workers
end
