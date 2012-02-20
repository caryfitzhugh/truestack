require 'test_helper'

# Start up collector

class CollectorTest < MiniTest::Unit::TestCase
  def self.test(name, &block)
    define_method("test_"+name.gsub(/\W/,'_'), block)
  end
  def setup
    # Clean out mongo
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    @test_url = "http://127.0.0.1:10000"
    @collector_pid = Process.spawn("RAILS_ENV=#{ENV['RAILS_ENV']} rake workers:collector:start[#{@test_url}] --trace", :out => [Rails.root.join('log','test.log').to_s, 'w'] )
    sleep 10
    @access_token = AccessToken.make!
    opts = {
             secret:  @access_token.secret,
             key:     @access_token.key,
             nonce: Time.now.to_i.to_s + OpenSSL::Random.random_bytes(32).unpack("H*")[0]
             }
    @client = TruestackClient::Websocket.new(@test_url,opts)
    super
  end

  def teardown
    @client.close if @client.connected?
    AccessToken.destroy_all
    Process.kill("SIGTERM", @collector_pid)
    super
  end

  test "that request events are queued" do
    @client.connect

    @client.request('test_request', Time.now.to_i, {action: {s: 0, d:300}})
    @client.request('test_request', Time.now.to_i, {action: {s: 0, d:300}})

    # Should only show up in correct spots
    sleep 1

    @access_token.user_application.latest_deployment.reload
    assert_equal 2, @access_token.user_application.latest_deployment.application_actions.get('action').count
    assert_equal 300, @access_token.user_application.latest_deployment.application_actions.get('action').duration_mean
  end
end
