$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")
require 'test_helper'

class UserProfileControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get home" do
    sign_in(User.make!)
    get :show
    assert_response :success
  end

  test "should be able to reset token" do
    user = User.make!
    sign_in(user)

    get :show
    assert_response :success

    post :reset_token
    assert_response :redirect

    user.reload
    assert !user.api_token.blank?
  end
end
