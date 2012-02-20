require 'test_helper'

class UserApplicationsControllerTest < ActionController::TestCase
  test "should get show" do
    app = UserApplication.make!
    get :show, :id => app.id
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
