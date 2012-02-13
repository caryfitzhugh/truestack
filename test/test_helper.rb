ENV["RAILS_ENV"] = "test"
# Must go first!
require File.expand_path('./helpers/minitest_fix', File.dirname(__FILE__))

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require File.expand_path(File.dirname(__FILE__) + '/blueprints')

class ActiveSupport::TestCase
end
