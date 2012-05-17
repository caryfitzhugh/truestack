require 'test_helper'

class TimeSliceTest < ActiveSupport::TestCase
  test "do create a single time slice" do
    TimeSlice.add_request('app_id', 'deploy:123', 'controller#action', mock_actions)
    assert_equal TimeSlice::Day.first['deploy:123']['_count'], 1
    assert_equal TimeSlice::Hour.first['deploy:123']['_count'], 1
    TimeSlice::Day.collection_name, TimeSlice::Day.first.attributes
    TimeSlice::Hour.collection_name, TimeSlice::Hour.first.attributes
  end

  test "do create a browser timing event" do
    TimeSlice.add_browser_ready_timing('app_id', 'deploy:123', 'controller#action', (Time.now.to_f * 1000).to_i, 400)
    assert_equal TimeSlice::Hour.first['deploy:123']['_count'], 1
    assert_equal TimeSlice::Day.first['deploy:123']['_count'], 1

    TimeSlice.add_browser_ready_timing('app_id', 'deploy:123', 'controller#action', (Time.now.to_f * 1000).to_i, 400)
    assert_equal TimeSlice::Hour.first['deploy:123']['_count'], 1
    assert_equal TimeSlice::Day.first['deploy:123']['_count'], 1
  end
end
