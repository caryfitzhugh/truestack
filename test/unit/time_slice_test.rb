require 'test_helper'

class TimeSliceTest < ActiveSupport::TestCase
  test "do create a single time slice" do
    skip
    TimeSlice.add_request('n', '1', [], "MD5-1212123")
  end
end
