$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")
require 'test_helper'

class CollectorWorkersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup do
    @collector_worker = CollectorWorker.make!
  end

  test "should get index" do
    sign_in(User.make!)
    get :index
    assert_response :success
    assert_not_nil assigns(:collector_workers)
  end

  test "should show collector_worker" do
    sign_in(User.make!)
    get :show, id: @collector_worker
    assert_response :success
  end
end
