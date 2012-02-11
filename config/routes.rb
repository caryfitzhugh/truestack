Truestack::Application.routes.draw do
  match "/director" => "director#index"

  resources :collector_workers
end
