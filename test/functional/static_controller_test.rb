$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")
require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get home" do
    sign_in(User.make!)
    get :home
    assert_response :success
  end

  test "should get about" do
    sign_in(User.make!)
    get :about
    assert_response :success
  end

end
