require 'test_helper'

class UserApplicationTest < ActiveSupport::TestCase
  test "we can create an app and push in some request data" do
    application = UserApplication.make!
    application.add_request("Controller#action", mock_actions)
  end

  test "user app has access_tokens" do
    app = UserApplication.make!

    assert_equal 1, app.access_tokens.length
  end

  test "create startups from different hosts, only one startup record" do
    app = UserApplication.make!
    app.add_startup(0, "host1", "commt_hash", mock_methods)
    app.add_startup(0, "host2", "commt_hash", mock_methods)
    app.add_startup(0, "host3", "commt_hash", mock_methods)

    assert_equal 1, Deployment.count
    assert_equal 3, Deployment.last.hosts.count
  end
end
