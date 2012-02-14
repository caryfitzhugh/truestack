require 'test_helper'

class AccessTokensControllerTest < ActionController::TestCase
  setup do
    @access_token = AccessToken.make!
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:access_tokens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create access_token" do
    assert_difference('AccessToken.count') do
      post :create, access_token: {secret: 'new secret', key: 'new key'    }
    end

    assert_redirected_to access_token_path(assigns(:access_token))
  end

  test "should show access_token" do
    get :show, id: @access_token
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @access_token
    assert_response :success
  end

  test "should update access_token" do
    put :update, id: @access_token, access_token: @access_token.attributes
    assert_redirected_to access_token_path(assigns(:access_token))
  end

  test "should destroy access_token" do
    assert_difference('AccessToken.count', -1) do
      delete :destroy, id: @access_token
    end

    assert_redirected_to access_tokens_path
  end
end
