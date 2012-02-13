require 'base64'
require 'openssl'

class AccessToken < ActiveRecord::Base
  # Is the provided nonce and token valid?
  def valid_signature?(nonce, their_token)
    digest = OpenSSL::Digest::Digest.new('sha256')
    our_token  = OpenSSL::HMAC.hexdigest(digest, self.secret, nonce)
    our_token == their_token
  end
  def self.create_signature(secret, nonce)
    digest = OpenSSL::Digest::Digest.new('sha256')
    OpenSSL::HMAC.hexdigest(digest, secret, nonce)
  end
end
