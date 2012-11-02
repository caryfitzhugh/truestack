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
