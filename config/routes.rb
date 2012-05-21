Truestack::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' }

  get "about" => "static#about"

  authenticated :user do
    root to: 'user_applications#index'
  end

  get 'bootstrap/base-css' => 'static#base_css'
  get 'bootstrap/scaffolding' => 'static#scaffolding'
  get 'bootstrap/components' => 'static#components'
  root to: 'signups#new'

  get  "signups/thanks" => "signups#thanks"
  post "signups" => "signups#create"
  get  "signups" => "signups#new"

  resources :user_applications, :path => "apps" , :as => "apps", :path_prefix => "apps" do
    post :reset_token
  end

  post  "/app/startup"           => "user_application_fallback_controller#create_startup_event"
  post  "/app/metric"            => "user_application_fallback_controller#create_metric_event"
  post  "/app/exception"         => "user_application_fallback_controller#create_exception_event"

  get   "/app/browser"           => "user_application_fallback_controller#create_browser_event"
  get   "/app/browser_event"     => "user_application_fallback_controller#create_browser_event"

  match "/app/request"           => "user_application_fallback_controller#create_request_event"

  match "/director" => "director#index"
end
