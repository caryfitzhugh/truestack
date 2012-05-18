require 'test_helper'

class CallTreeTest < ActiveSupport::TestCase
  test "create a tree" do
    tree = CallTree.new(mock_actions)
  end
end
