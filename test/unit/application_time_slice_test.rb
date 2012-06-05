require 'test_helper'

class ApplicationTimeSliceTest < ActiveSupport::TestCase
  test "you can add browser timings" do
    app = UserApplication.make!
    ApplicationTimeSlice.add_browser_ready(app, "request#method", TruestackClient.to_timestamp(Time.now), 100)
    ApplicationTimeSlice.add_exception(app, "request#method", "this_threw_an_exception:apple.rb:32", TruestackClient.to_timestamp(Time.now))
    ApplicationTimeSlice.add_request(app, "request#method", mock_actions)
  end
end
