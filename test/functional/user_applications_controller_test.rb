require 'test_helper'

class UserApplicationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test "should get show" do
    sign_in(user = User.make!)
    app = UserApplication.make!
    get :show, :id => app.id
    assert_response :success
  end

  test "should get index" do
    sign_in(user = User.make!)
    get :index
    assert_response :success
  end
end
