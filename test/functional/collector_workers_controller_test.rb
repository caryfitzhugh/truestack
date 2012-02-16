require 'test_helper'

class CollectorWorkersControllerTest < ActionController::TestCase
  setup do
    @collector_worker = CollectorWorker.make!
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collector_workers)
  end

  test "should show collector_worker" do
    get :show, id: @collector_worker
    assert_response :success
  end
end
