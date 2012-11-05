$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")

require 'test_helper'

class UserApplicationTest < ActiveSupport::TestCase
  test "access count" do
    application = UserApplication.make!
    assert_difference "application.reload; application.access_count", 1 do
      application.add_request("Controller#action", mock_actions)
      application.save!
    end
  end

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
    assert_difference "app.reload; app.access_count", 3 do
      app.add_startup(0, "host1", "commt_hash", mock_methods)
      app.add_startup(0, "host2", "commt_hash", mock_methods)
      app.add_startup(0, "host3", "commt_hash", mock_methods)
      app.save!
    end

    assert_equal 1, Deployment.count
    assert_equal 3, Deployment.last.hosts.count
  end
end
