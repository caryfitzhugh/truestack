require 'test_helper'

class ClientApiTest < ActionDispatch::IntegrationTest
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
      request_name:       'Controller#action',
      tstart:   Time.now.to_s,
      backtrace: [
        'a/b/c:45',
        'd/e/f:22'
      ],
      env: { 'http_accept' => "Anything" }
    }.to_json

    post "app/exception", body,
        { 'TrueStack-Access-Key' => access_token.key ,
          :type => :json}

    assert_response :accepted
  end

  test "can ingest a request from webhook" do
    access_token = AccessToken.make!
    body = {
      name: 'Controller#action',
      actions: mock_actions,
    }.to_json

    post "app/request", body,
        { 'TrueStack-Access-Key' => access_token.key ,
          :type => :json}

    assert_response :accepted
  end
end
