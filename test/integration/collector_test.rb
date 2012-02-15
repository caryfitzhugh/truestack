require 'test_helper'
require 'helpers/websocket_client'

# Start up collector

class CollectorTest < MiniTest::Unit::TestCase
  def self.test(name, &block)
    define_method("test_"+name.gsub(/\W/,'_'), block)
  end
  def setup
    @test_url = "http://127.0.0.1:10000"
    @collector_pid = Process.spawn("RAILS_ENV=#{ENV['RAILS_ENV']} rake workers:collector:start[#{@test_url}]", :out => [Rails.root.join('log','test.log').to_s, 'w'] )
    sleep 10
    @access_token = AccessToken.make!
    opts = { protocol:'01282012.client.truestack.com',
             secret:  @access_token.secret,
             key:     @access_token.key,
             nonce: Time.now.to_i.to_s + OpenSSL::Random.random_bytes(32).unpack("H*")[0]
             }
    @client = WebsocketClient.new(@test_url,opts)
    super
  end

  def teardown
    @client.close if @client.connected?
    AccessToken.destroy_all
    Process.kill("SIGTERM", @collector_pid)
    super
  end

  test "that we can not connect with a wimpy nonce" do
    @client.connect(nonce: 'notvalid')
    begin
      read = @client.write_data("shouldn't be able to")
      fail
    rescue Exception => e
      # This is ok.
    end
  end

  test "that we can connect with valid credentials" do
    @client.connect

    @client.write_data("Writing data")
  end
  test "that we can not connect with invalid secret" do
    @client.connect(secret: 'notvalid')
    begin
      read = @client.write_data("shouldn't be able to")
      fail "Connected?"
    rescue Exception => e
      # This is ok.
    end
  end
  test "that we can not connect with invalid protocol" do
    @client.connect(protocol: 'notvalid')
    begin
      read = @client.write_data("shouldn't be able to")
      fail "Connected?"
    rescue Exception => e
      # This is ok.
    end
  end
  test "that we can not connect with invalid app_key" do
    @client.connect(key: 'notvalid')
    begin
      read = @client.write_data("shouldn't be able to")
      fail "Connected?"
    rescue Exception => e
      # This is ok.
    end
  end
end
