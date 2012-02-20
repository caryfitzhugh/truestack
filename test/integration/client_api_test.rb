require 'test_helper'

class ClientApiTest < ActionDispatch::IntegrationTest
  test "can ingest a request from webhook" do
    access_token = AccessToken.make!
    nonce        = Time.now.to_i.to_s + OpenSSL::Random.random_bytes(32).unpack("H*")[0]
    body = {message: { type: 'request', name: 'test', methods: {'method_1' => {s: 0, d: 300}}}}.to_json

    post "app/event", body,
        { 'TrueStack-Access-Key' => access_token.key,
          'TrueStack-Access-Token' => access_token.create_signature(nonce),
          'TrueStack-Access-Nonce' => nonce,
          :type => :json}


    assert_response :accepted
  end

  test "posting that deployment is done (and validate the POST)" do
    access_token = AccessToken.make!
    nonce        = Time.now.to_i.to_s + OpenSSL::Random.random_bytes(32).unpack("H*")[0]

    post "/deployments", {message: { commit_id: 'foo'}}.to_json,
        {'TrueStack-Access-Key' => access_token.key, 'TrueStack-Access-Token' => access_token.create_signature(nonce),
          'TrueStack-Access-Nonce' => nonce}
    assert_response :accepted
  end

end
