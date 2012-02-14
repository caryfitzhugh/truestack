class Deployment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :commit_id,   type: String
  field :commit_info, type: Hash
  field :methods,     type: Array
  belongs_to :user_application
end
