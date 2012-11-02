
Truestack::Application.routes.draw do
  resources :subscriptions

  match "/director" => "director#index"
  constraints(:subdomain => 'director') do
    match "/" => "director#index"
  end

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' }

  get "about" => "static#about"
  get "mongo" => "static#mongo"
  get "home"  => "static#home"

  authenticated :user do
    root to: 'user_applications#index'
  end

  get 'bootstrap/base-css' => 'static#base_css'
  get 'bootstrap/scaffolding' => 'static#scaffolding'
  get 'bootstrap/components' => 'static#components'

  get  "signups/thanks" => "signups#thanks"
  post "signups" => "signups#create"
  get  "signups" => "signups#new"

  get "profile" => "user_profile#show", :as => :profile
  post "profile" => "user_profile#update"
  post "profile/reset_token" => "user_profile#reset_token", :as => "profile_reset_api_token"

  resources :user_applications, :path => "apps" , :as => "apps" do
    post :reset_token
    post :purge_data
  end

  resource "admin", :only => [:show] do
    resources :collector_workers
  end

  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'

  # Mount the services from the services directory.
  Dir[Rails.root.join("app","services","*_service.rb")].each do |file|
    name = File.basename(file).split('.',2).first.downcase

    if (name != "application_service")
      constant= "::Services::#{name.camelize}".constantize
      Rails.logger.info "Mounting #{constant} to #{constant.rack_base("apl")}"
      mount constant => constant.rack_base("api")
    end
  end

  root to: 'signups#new'
end
