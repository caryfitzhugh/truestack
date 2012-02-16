require 'test_helper'

class ApplicationActionsControllerTest < ActionController::TestCase
  test "can ingest a request from webhook" do
    access_token = AccessToken.make!
    nonce        = Time.now.to_i.to_s + OpenSSL::Random.random_bytes(32).unpack("H*")[0]
    post :create, key: access_token.key, nonce: nonce, token: access_token.create_signature(nonce),
      message: { type: 'request', name: 'test', methods: {'method_1' => 300}}
    assert_response :accepted
  end
  test "can't ingest a invalid request from webhook" do
    access_token = AccessToken.make!
    nonce        = Time.now.to_i.to_s + OpenSSL::Random.random_bytes(32).unpack("H*")[0]
    post :create, key: access_token.key, nonce: nonce, token: 'access_token',
      message: { type: 'request', name: 'test', methods: {'method_1' => 300}}
    assert_response 403
  end
  test "can't ingest a invalid nonce request from webhook" do
    access_token = AccessToken.make!
    nonce        = "invalid nonce"
    post :create, key: access_token.key, nonce: nonce, token: access_token.create_signature(nonce),
      message: { type: 'request', name: 'test', methods: {'method_1' => 300}}
    assert_response 403
  end
end
