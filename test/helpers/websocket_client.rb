require File.join(File.dirname(__FILE__), 'websocket_client','ws_cli')
require 'uri'
require 'base64'
require 'openssl'

class WebsocketClient
  def initialize(url, opts={})
    @opts = opts
    @url = URI.parse(url)
    @proto = :hybi07

    log = Rails.logger

    @client = WSClient.new(log, {:host => @url.host, :port => @url.port, :proto => @proto, :frame_compression => false})
  end

  def method_missing(*args)
    name = args.shift
    @client.send(name, *args)
  end

  def connect(opts={})
    opts = @opts.merge(opts)

    signature = AccessToken.create_signature(opts[:secret], opts[:nonce])

    sec_headers = {}
    sec_headers["TrueStack-Access-Key"] = opts[:key]
    sec_headers["TrueStack-Access-Token"]= signature
    sec_headers["TrueStack-Access-Nonce"]= opts[:nonce]

    @client.connect([opts[:protocol]], sec_headers)
  end

  def connected?
    @client.connected?
  end
end
