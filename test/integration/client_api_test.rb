require 'test_helper'

class ClientApiTest < ActionDispatch::IntegrationTest
  test "can ingest a request from webhook" do
    access_token = AccessToken.make!
    nonce        = Time.now.to_i.to_s + OpenSSL::Random.random_bytes(32).unpack("H*")[0]
    body = {
      name: 'Controller#action',
      request_id: SecureRandom.hex(8),
      actions: {
        'klass#method1' => [{
          tstart: 0,
          tend:   10
        }],
        'klass#method2' => [
          {
            tstart: 0,
            tend:   4
          },
          {
            tstart: 5,
            tend:   10
          }
        ]
      }
    }.to_json

    post "app/request", body,
        { 'TrueStack-Access-Key' => access_token.key ,
          :type => :json}

    assert_response :accepted
  end

  test "posting that deployment is done (and validate the POST)" do
    access_token = AccessToken.make!

    post "/app/deployments", { commit_id: 'foo'}.to_json,
        {'TrueStack-Access-Key' => access_token.key}
    assert_response :accepted
  end

end
