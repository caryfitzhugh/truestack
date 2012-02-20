class Deployment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :commit_id,   type: String
  field :commit_info, type: Hash

  belongs_to :user_application

  validates_presence_of :commit_id
  validates_presence_of :user_application
end
