require 'test_helper'

class UserApplicationTest < ActiveSupport::TestCase
  test "we can create an app and push in some request data" do
    application = UserApplication.make!
    application.add_request("Controller#action", mock_actions)
  end

  test "user app has access_tokens" do
    app = UserApplication.make!

    assert !!app.access_token
  end

  test "create startups from different hosts, only one startup record" do
    app = UserApplication.make!
    app.add_startup(0, "host1", "commt_hash", mock_methods)
    app.add_startup(0, "host2", "commt_hash", mock_methods)
    app.add_startup(0, "host3", "commt_hash", mock_methods)

    assert_equal 1, Deployment.count
    assert_equal 3, Deployment.last.hosts.count
  end

  test "create request and browser and see correct timings" do
    application = UserApplication.make!
    now = TruestackClient.to_timestamp(Time.now)
    application.add_request("Controller#action", 'klass#method1' => [{
          tstart: now.to_s,
          tend:   (now + 1000).to_s
        }])

    application.add_browser_ready_timing("Controller#action", now, now+500)
    ts = TimeSlice::Hour.last['default-deploy-key']
    assert_equal 1, TimeSlice::Hour.count
    assert_equal 1, ts["_requests"]["_count"]
    assert_equal 1000, ts["_requests"]["_mean"]
    assert_equal 1, ts["_browser"]["_count"]
    assert_equal 500, ts["_browser"]["_mean"]

    # Test _methods
    assert_equal 1,   ts["_methods"]["browser#ready"]["_count"]
    assert_equal 500, ts["_methods"]["browser#ready"]["_mean"]
    assert_equal 1,   ts["_methods"]["browser#ready"]["_requests"]["Controller#action"]["_count"]
    assert_equal 500, ts["_methods"]["browser#ready"]["_requests"]["Controller#action"]["_mean"]
  end
end
