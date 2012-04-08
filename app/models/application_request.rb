class ApplicationRequest
  include Mongoid::Document

  field :name,          type: String
  field :request_id,    type: String
  field :data,          type: Array, default: []
  key   :name
  validates_presence_of :name
  belongs_to :time_bucket

  def update_request(actions)
    data << actions
  end
end
