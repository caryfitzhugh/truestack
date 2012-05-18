require 'test_helper'

class ClientApiTest < ActionDispatch::IntegrationTest
  test "can ingest a browser report from webhook" do
    access_token = AccessToken.make!
    body = {
      action: "truestack#method",
      tstart:   TruestackClient.to_timestamp(Time.now),
      tend:     TruestackClient.to_timestamp(Time.now),
      'TrueStack-Access-Key' => access_token.key
    }

    get "app/browser", body

    assert_response :accepted
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
        { 'TrueStack-Access-Key' => access_token.key ,
          :type => :json}

    assert_response :accepted
  end

  test "can ingest an exception from webhook" do
    access_token = AccessToken.make!
    body = {
      exception_name:     'ActiveRecord::NotFoundException',
      request_name:       'controller#action',
      failed_in_method: mock_failed_in_method,
      actions:          mock_actions,
      tstart:           TruestackClient.to_timestamp(Time.now),
      backtrace: [
        'a/b/c:45',
        'd/e/f:22'
      ],
      env: { 'http_accept' => "Anything" }
    }.to_json

    post "app/exception", body,
        { 'TrueStack-Access-Key' => access_token.key ,
          :type => :json}

    assert_equal 1, TimeSlice::Day.first['default-deploy-key']['_exceptions']['ActiveRecord::NotFoundException@a/b/c:45']['_times'].count
    assert_response :accepted
  end

  test "can ingest a request from webhook" do
    access_token = AccessToken.make!
    body = {
      name: 'controller#action',
      actions: mock_actions,
    }.to_json

    post "app/request", body,
        { 'TrueStack-Access-Key' => access_token.key ,
          :type => :json}

    assert_response :accepted
  end
end
