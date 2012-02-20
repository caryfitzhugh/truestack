source 'https://rubygems.org'

gem 'rails', '3.2.1'

gem 'pg'

group :test do
  gem 'machinist', '>= 2.0.0.beta2'
  gem 'machinist_mongo', :git => 'https://github.com/nmerouze/machinist_mongo.git', :require => 'machinist/mongoid', :branch => 'machinist2'
end

gem "mongoid", "~> 2.4"
gem "bson_ext", "~> 1.5"

gem 'haml-rails'
gem 'sass-rails',   '~> 3.2.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'pry', :git => "git://github.com/pry/pry.git"
  #gem "ruby-debug19", :require => "ruby-debug"
end
group :test do
  gem 'pry', :git => "git://github.com/pry/pry.git"
  gem "minitest"
  gem 'truestack_client', :git => "git@github.com:caryfitzhugh/truestack_client.git"
end

gem 'jquery-rails'

# Collector
gem 'eventmachine'
gem 'em-websocket'
