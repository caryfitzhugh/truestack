$:.unshift File.expand_path(File.dirname(__FILE__) + "/..")

require 'test_helper'

class ClientApiTest < ActionDispatch::IntegrationTest
  test "can ingest a browser report from img src" do
    access_token = AccessToken.make!
    body = {
      :truestack => {
        action: "truestack#method",
        tstart:   TruestackClient.to_timestamp(Time.now),
        tend:     TruestackClient.to_timestamp(Time.now)
      },
      'Truestack-Access-Key' => access_token.key
    }

    get "app/browser", body, { :type => :json}

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

    post "app/startup", body,
        { 'Truestack-Access-Key' => access_token.key ,
          :type => :json}

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

    post "app/exception", body,
        { 'Truestack-Access-Key' => access_token.key ,
          :type => :json}

    assert_response :accepted
  end

  test "can ingest a request from webhook" do
    access_token = AccessToken.make!
    body = {
      name: 'controller#action',
      actions: mock_actions,
    }.to_json

    post "app/request", body,
        { 'Truestack-Access-Key' => access_token.key ,
          :type => :json}

    assert_response :accepted
  end
end
