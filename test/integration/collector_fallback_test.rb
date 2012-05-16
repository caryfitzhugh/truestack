require 'test_helper'
require 'net/http'

class CollectorFallbackTest < MiniTest::Unit::TestCase
  def self.test(name, &block)
    define_method("test_"+name.gsub(/\W/,'_'), block)
  end
  def setup
    # Clean out mongo
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    @test_url = "http://127.0.0.1:10000"
    @server_pid = Process.spawn({'RAILS_ENV' => ENV['RAILS_ENV']},   "bundle exec rails s -p 3005",
      [:err, :out] => [Rails.root.join('log','test.log').to_s, 'a'])
    tries = 0

    while !is_port_open?('127.0.0.1', 3005) && tries < 20
      tries += 1
      sleep 1
    end

    @access_token = AccessToken.make!
    @client = TruestackClient.configure do |c|
      c.host   = "http://127.0.0.1:3005/"  # This is the server url
      c.key    = @access_token.key
      c.logger = Rails.logger
    end

    super
  end

  def teardown
    AccessToken.destroy_all
    Process.kill("SIGKILL", @server_pid)
    super
  end

  test "websocket is directed to" do
    assert_equal TruestackClient::HTTP, TruestackClient.websocket_or_http.class
  end

  test "that exceptions are passed in" do
    begin
      raise "An Exception"
    rescue Exception => e
      assert_equal TruestackClient::HTTP, TruestackClient.websocket_or_http.class
      TruestackClient.exception("Foo#foo", Time.now, mock_failed_in_method, mock_actions, e, { request: "env"})
      sleep 1
    end
  end

  test "that startups are passed in" do
    before_as = Deployment.count
    assert_equal TruestackClient::HTTP, TruestackClient.websocket_or_http.class
    TruestackClient.startup("Applesauce", "192.168.1.1", mock_methods)
    sleep 5
    assert_equal 1 + before_as, Deployment.count
  end

  test "that request events are queued" do
    assert_equal TruestackClient::HTTP, TruestackClient.websocket_or_http.class
    TruestackClient.request('test_request', mock_actions)

    # Should only show up in correct spots
    sleep 1
    assert_equal 1, TimeSlice.first['default-deploy-key']['_count']
  end

  private

  require 'socket'
  require 'timeout'

  def is_port_open?(ip, port)
    begin
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end
    return false
  end
end
