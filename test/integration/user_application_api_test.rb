$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")

require 'test_helper'

class UserApplicationApiTest < ActionDispatch::IntegrationTest
  test "bad authentication" do
    user = User.make!

    post "api/apps", { :name => "New Application" }, 'Truestack-Access-Key' => "invalid"
    assert_response 403
  end

  test "destroy existing" do
    user = User.make!

    app = UserApplication.make!(user: user)

    assert_difference "UserApplication.count", -1 do
      delete "api/apps/#{app.id}", {}, 'Truestack-Access-Key' => user.api_token
      assert_response 200
    end
  end

  test "purge an application" do
    user = User.make!

    app = UserApplication.make!(user: user)

    post "api/apps/#{app.id}/purge_data", {}, 'Truestack-Access-Key' => user.api_token

    assert_response 200
  end
  test "getting access counters from a service" do
    user = User.make!

    app = UserApplication.make!(user: user)
    access_token = app.access_token
    body = {
      commit_id:'12312312312312123',
      host_id:  "112j3jk133/asdfasdf/192.323.33.21/4",
      tstart:   TruestackClient.to_timestamp(Time.now),
      methods:  mock_methods
    }.to_json

    post "api/collector/startup", body,
        { 'Truestack-Access-Key' => access_token.key , :type => :json}

    assert_response :accepted

    get "api/apps/#{app.id}/access_counters", {}, 'Truestack-Access-Key' => user.api_token

    message = ActiveSupport::JSON.decode(response.body)
    assert_response 200
    assert_equal 1, message.length
    assert_equal 1, message.first['count']
  end

  test "ok authentication - create new" do
    user = User.make!

    assert_difference "user.reload && user.user_applications.count" , 1 do
      assert_difference "UserApplication.count" , 1 do
        post "api/apps", { :name => "New Application" },
          'Truestack-Access-Key' => user.api_token
        assert_response 200
      end
    end

    assert_difference "user.reload && user.user_applications.count" , 0 do
      assert_difference "UserApplication.count" , 0 do
        post "api/apps", { :name => "New Application" },
          'Truestack-Access-Key' => user.api_token
        assert_response 500
      end
    end
  end
end
