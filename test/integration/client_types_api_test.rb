$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")

require 'test_helper'

class ClientTypesApiTest < ActionDispatch::IntegrationTest
  def setup
    ClientType.create({start_on: Time.now.months_ago(2).change(day: 1, hour: 0), app: 'old', client: 'old'})
    ClientType.create({start_on: Time.now.months_ago(1).change(day: 1, hour: 0), app: 'prev', client: 'prev'})
    ClientType.create({start_on: Time.now.change(day: 1, hour: 0), app: 'now', client: 'now'})
    @user = User.make!(:admin => true )
  end
  test "all view" do
    get "api/client_types/all", {}, {'Truestack-Access-Key' => @user.api_token}
    assert_response :success

    message = ActiveSupport::JSON.decode(response.body)
    assert_equal 3, message.length
  end

  test "previous month" do
    get "api/client_types/last_month", {}, {'Truestack-Access-Key' => @user.api_token}
    assert_response :success

    message = ActiveSupport::JSON.decode(response.body)
    assert_equal 1, message.length
    assert_equal 'prev', message.first['app']
  end
  test "current month" do
    get "api/client_types/", {}, {'Truestack-Access-Key' => @user.api_token}
    assert_response :success

    message = ActiveSupport::JSON.decode(response.body)
    assert_equal 1, message.length
    assert_equal 'now', message.first['app']
  end
end
