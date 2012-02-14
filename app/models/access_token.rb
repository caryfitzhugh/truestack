require 'base64'
require 'openssl'

class AccessToken
  include Mongoid::Document
  include Mongoid::Timestamps
  field :secret,  type: String
  field :key,     type: String
  belongs_to :user_application

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
