$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")

require 'test_helper'

class CollectorApiTest < ActionDispatch::IntegrationTest
  test "can track client types" do
    access_token = AccessToken.make!
    body = {
      :truestack => {
        name:     "truestack#method",
        tstart:   TruestackClient.to_timestamp(Time.now),
        tend:     TruestackClient.to_timestamp(Time.now)
      }
    }.to_json

    assert_difference "ClientType.count", 1 do
      post "api/collector/startup", body,
        {'Truestack-Access-Key' => access_token.key,
        'Truestack-Client-Type' => "1.0|rails-3.2"}
      assert_response :success
    end

    admin = User.make!(:admin => true)
    get "api/client_types/", {}, {'Truestack-Access-Key' => admin.api_token}

    message = ActiveSupport::JSON.decode(response.body)
    assert_equal   1, message.length
    assert_equal   'rails-3.2', message.first['app']
    assert_equal   '1.0', message.first['client']
  end

  test "can ingest a browser report from img src" do
    access_token = AccessToken.make!
    body = {
      :truestack => {
        name:     "truestack#method",
        tstart:   TruestackClient.to_timestamp(Time.now),
        tend:     TruestackClient.to_timestamp(Time.now)
      },
      'Truestack-Access-Key' => access_token.key
    }

    get "api/collector/browser", body

    assert_response :success
  end

  test "can ingest a startup from webhook" do
    access_token = AccessToken.make!
    body = {
      commit_id:'12312312312312123',
      host_id:  "112j3jk133/asdfasdf/192.323.33.21/4",
      tstart:   TruestackClient.to_timestamp(Time.now),
      methods:  mock_methods
    }.to_json

    post "api/collector/startup", body,
        { 'Truestack-Access-Key' => access_token.key , :type => :json}

    assert_response :accepted
  end

  test "can ingest an exception from webhook" do
    access_token = AccessToken.make!
    body = {
      exception_name:     'ActiveRecord::NotFoundException',
      request_name:       'controller#action',
      failed_in_method:   mock_failed_in_method,
      actions:            mock_actions,
      tstart:             TruestackClient.to_timestamp(Time.now)
    }.to_json

    post "api/collector/exception", body,
        { 'Truestack-Access-Key' => access_token.key , :type => :json}

    assert_response :accepted
  end

  test "can ingest a request from webhook" do
    access_token = AccessToken.make!
    body = {
      name: 'controller#action',
      actions: mock_actions,
    }.to_json

    post "api/collector/request", body,
        { 'Truestack-Access-Key' => access_token.key , :type => :json}

    assert_response :accepted
  end
end
