ENV["RAILS_ENV"] = "test"
# Must go first!
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require File.expand_path(File.dirname(__FILE__) + '/blueprints')

class ActiveSupport::TestCase
  setup :global_setup

  private

  def global_setup
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
