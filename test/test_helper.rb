ENV["RAILS_ENV"] = "test"
# Must go first!
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require File.expand_path(File.dirname(__FILE__) + '/blueprints')

class ActiveSupport::TestCase
  setup     :clean_out_mongo
  teardown  :clean_out_mongo

  private

  def clean_out_mongo
    Mongoid.purge!
  end
end
