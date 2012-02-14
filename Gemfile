source 'https://rubygems.org'

gem 'rails', '3.2.1'

gem 'pg'

group :test do
  gem 'machinist', '>= 2.0.0.beta2'
end

gem 'mongo_mapper'
gem 'bson_ext'

gem 'haml-rails'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'pry', :git => "git://github.com/pry/pry.git"
end
group :test do
  gem 'pry', :git => "git://github.com/pry/pry.git"
  gem "minitest"
end

gem 'jquery-rails'

# Collector
gem 'eventmachine'
gem 'em-websocket', git: "git@github.com:caryfitzhugh/em-websocket.git"
