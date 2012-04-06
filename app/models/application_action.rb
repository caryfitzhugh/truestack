# Defines and traces an applications entire history
# of actions and their stats
class ApplicationAction
  include Mongoid::Document
  include RunningStats
  field :name,  type: String
  key   :name

  embedded_in :time_bucket
  validates_presence_of :name
end
