class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :user_applications
  has_many :users
end
