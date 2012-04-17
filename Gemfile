source 'https://rubygems.org'

gem 'rails', '3.2.1'

# Database
gem "mongoid", "~> 2.4"
gem "bson_ext", "~> 1.5"

# Templating
gem 'haml-rails'
gem 'slim-rails'

# Roles & Permissions
gem 'devise'
# NOTE: cancan must come after mongoid in this file
# See: https://github.com/ryanb/cancan/issues/553
gem 'cancan'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bourbon'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'sass-rails', '~> 3.1'
  gem 'bootstrap-sass', '>= 2.0.2'
  gem 'bootswatch-rails'
end

group :development do
  gem 'pry', :git => "git://github.com/pry/pry.git"
  gem 'pry-nav', :git => "https://github.com/nixme/pry-nav.git"
  gem 'debugger'
  #gem "ruby-debug19", :require => "ruby-debug"
end

group :test do
  gem 'pry', :git => "git://github.com/pry/pry.git"
  gem 'pry-nav', :git => "https://github.com/nixme/pry-nav.git"
  gem "minitest"
  gem 'truestack_client', :git => "git@github.com:caryfitzhugh/truestack_client.git"
  gem 'machinist', '>= 2.0.0.beta2'
  gem 'machinist_mongo', :git => 'https://github.com/nmerouze/machinist_mongo.git', :require => 'machinist/mongoid', :branch => 'machinist2'
end

gem 'jquery-rails'
gem 'simple_form'

# Collector
gem 'eventmachine'
gem 'em-websocket'
