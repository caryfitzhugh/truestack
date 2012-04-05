require 'base64'
require 'openssl'

class AccessToken
  include Mongoid::Document
  include Mongoid::Timestamps
  field :key,     type: String
  belongs_to :user_application

  validates_uniqueness_of :key
  before_validation :create_key

  private

  def create_key
    self.key = SecureRandom.hex(10) if self.key.blank?
  end
end
