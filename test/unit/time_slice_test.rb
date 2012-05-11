require 'test_helper'

class TimeSliceTest < ActiveSupport::TestCase
  test "do create a single time slice" do
    TimeSlice.add_request('app_id', 'deploy:123', 'controller#action', mock_actions)
  end
end
