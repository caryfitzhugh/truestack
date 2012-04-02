require 'base64'
require 'openssl'

class AccessToken
  include Mongoid::Document
  include Mongoid::Timestamps
  field :secret,  type: String
  field :key,     type: String
  belongs_to :user_application

  validates_uniqueness_of :key
  before_validation :create_key, :create_secret

  # Is the provided nonce and token valid?
  def valid_signature?(nonce, their_token)
    digest = OpenSSL::Digest::Digest.new('sha256')
    our_token  = OpenSSL::HMAC.hexdigest(digest, self.secret, nonce)
    our_token == their_token
  end
  def create_signature(nonce)
    AccessToken.create_signature(self.secret, nonce)
  end
  def self.create_signature(secret, nonce)
    digest = OpenSSL::Digest::Digest.new('sha256')
    OpenSSL::HMAC.hexdigest(digest, secret, nonce)
  end

  private

  def create_key
    self.key = SecureRandom.hex(10) if self.key.blank?
  end

  def create_secret
    self.secret = SecureRandom.hex(10) if self.secret.blank?
  end
end
