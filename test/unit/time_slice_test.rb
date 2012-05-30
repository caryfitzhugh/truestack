require 'test_helper'

class TimeSliceTest < ActiveSupport::TestCase
  test "do create a single time slice" do
    TimeSlice.add_request('app_id', 'deploy:123', 'controller#action', mock_actions)
    assert_equal TimeSlice::Day.first['deploy:123']['_requests']['_count'], 1
    assert_equal TimeSlice::Hour.first['deploy:123']['_requests']['_count'], 1
  end
  test "do create exception record in slice" do
    TimeSlice.add_request('app_id', 'deploy:123', 'controller#action', mock_actions)
    # "klass#method3"
    TimeSlice.add_exception('app_id', 'deploy:123', 'controller#action', "EXCEPTION_NAME", mock_failed_in_method, mock_actions, TruestackClient.to_timestamp(Time.now), ['backtrace:1'], {env: true})
  end
  test "do create a browser timing event" do
    TimeSlice.add_browser_ready_timing('app_id', 'deploy:123', 'controller#action', (Time.now.to_f * 1000).to_i, 400)
    assert_equal TimeSlice::Hour.first['deploy:123']["_browser"]['_count'], 1
    assert_equal TimeSlice::Day.first['deploy:123']["_browser"]['_count'], 1

    TimeSlice.add_browser_ready_timing('app_id', 'deploy:123', 'controller#action', (Time.now.to_f * 1000).to_i, 400)
    assert_equal TimeSlice::Hour.first['deploy:123']["_browser"]['_count'], 2
    assert_equal TimeSlice::Day.first['deploy:123']["_browser"]['_count'], 2
  end
end
