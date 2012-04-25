class ApplicationStartup
  include Mongoid::Document

  field :tstart,        type: Time
  field :host_id,         type: String
  field :commit_id,         type: String
  field :methods,    type: Array, default: []

  belongs_to :time_bucket
end
