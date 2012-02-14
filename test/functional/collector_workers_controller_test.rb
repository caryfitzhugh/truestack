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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collector_worker" do
    assert_difference('CollectorWorker.count') do
      post :create, collector_worker: { url: 'http://collector.foo.com'}
    end

    assert_redirected_to collector_worker_path(assigns(:collector_worker))
  end

  test "should show collector_worker" do
    get :show, id: @collector_worker
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @collector_worker
    assert_response :success
  end

  test "should update collector_worker" do
    put :update, id: @collector_worker, collector_worker: @collector_worker.attributes
    assert_redirected_to collector_worker_path(assigns(:collector_worker))
  end

  test "should destroy collector_worker" do
    assert_difference('CollectorWorker.count', -1) do
      delete :destroy, id: @collector_worker
    end

    assert_redirected_to collector_workers_path
  end
end
