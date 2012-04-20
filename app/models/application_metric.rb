class ApplicationMetric
  include Mongoid::Document

  field :name,          type: String
  field :value,         type: String
  field :created_at,    type: Time
  field :meta_data ,    type: Hash,   default: {}

  key   :name
  validates_presence_of :name, :value, :created_at
  belongs_to :time_bucket
end
