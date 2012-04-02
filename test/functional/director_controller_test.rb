require 'test_helper'

class DirectorControllerTest < ActionController::TestCase
  test "if there are no collectors, director sends a retry 503" do
    get :index
    assert_response 503
    assert_equal response.headers['Retry-After'], '30'
  end
  test "if there is a collector, directory redirects to that one" do
    CollectorWorker.make!(url: "http://foo.com" )
    get :index
    assert_response 307
    assert_redirected_to "http://foo.com"
  end
  test "director chooses least connected collector" do
    CollectorWorker.make!(url: "http://foo.com" )
    CollectorWorker.make!(url: "http://foo2.com", connection_count: 4 )
    get :index
    assert_response 307
    assert_redirected_to "http://foo.com"
  end
end
