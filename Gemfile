source 'https://rubygems.org'

gem 'rails', '3.2.1'

# Database
gem "mongoid", "~> 3.0.0.rc"

# Templating
gem 'haml-rails'
gem 'slim-rails'

gem 'stripe'

# Roles & Permissions
gem 'devise'
# NOTE: cancan must come after mongoid in this file
# See: https://github.com/ryanb/cancan/issues/553
gem 'cancan'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bootstrap-sass', '~> 2.0.2'
  gem 'font-awesome-sass-rails'
  gem 'bootswatch-rails', '~> 0.0.11'

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'debugger'
  gem 'quiet_assets'
end

group :test do
  gem 'pry'
  gem 'pry-nav'
  gem "minitest"
  gem 'machinist', '>= 2.0.0.beta2'
  gem 'machinist_mongo', :git => 'https://github.com/nmerouze/machinist_mongo.git', :require => 'machinist/mongoid', :branch => 'machinist2'
end

gem 'jquery-rails'
gem 'bourbon'
gem 'simple_form'
gem 'rails_admin'

gem 'pony'

# Client interactions
gem 'truestack_client', :git => "git@github.com:caryfitzhugh/truestack_client.git"

# Collector
gem 'eventmachine'
gem 'em-websocket'

gem "linefit", :git => "https://github.com/escline/linefit.git"
