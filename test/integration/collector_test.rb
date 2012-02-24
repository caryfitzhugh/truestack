require 'test_helper'
require 'net/http'

# Start up collector

class CollectorTest < MiniTest::Unit::TestCase
  def self.test(name, &block)
    define_method("test_"+name.gsub(/\W/,'_'), block)
  end
  def setup
    # Clean out mongo
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    @test_url = "http://127.0.0.1:10000"
    @server_pid = Process.spawn({'RAILS_ENV' => ENV['RAILS_ENV']},   "bundle exec rails s -p 3005",
      [:err, :out] => [Rails.root.join('log','test.log').to_s, 'a'])
    @collector_pid = Process.spawn({'RAILS_ENV' => ENV['RAILS_ENV']},"bundle exec rake workers:collector:start[#{@test_url}] --trace",
      [:err, :out] => [Rails.root.join('log','test.log').to_s, 'a'])
    tries = 0
    while !is_port_open?('127.0.0.1', 10000) && tries < 20
      tries += 1
      sleep 1
    end
    tries = 0
    while !is_port_open?('127.0.0.1', 3005) && tries < 20
      tries += 1
      sleep 1
    end

    @access_token = AccessToken.make!
    @client = TruestackClient.configure do |c|
      c.host   = "http://127.0.0.1:3005/"  # This is the server url
      c.secret = @access_token.secret
      c.key    = @access_token.key
      c.logger = Rails.logger
    end

    super
  end

  def teardown
    AccessToken.destroy_all
    Process.kill("SIGTERM", @collector_pid)
    Process.kill("SIGKILL", @server_pid)
    super
  end

  test "websocket is directed to" do
    assert_equal TruestackClient::Websocket, TruestackClient.websocket_or_http.class
  end

  test "that request events are queued" do
    TruestackClient.request('test_request', Time.now.to_i, {action: 300})
    TruestackClient.request('test_request', Time.now.to_i, {action: 300})

    # Should only show up in correct spots
    sleep 5

    @access_token.user_application.current_bucket.reload
    assert_equal 1, @access_token.user_application.time_buckets.map(&:application_actions).flatten.count
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
