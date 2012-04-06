# Defines and tracks requests actions (and their stats)
#
class RequestAction
  include Mongoid::Document
  include RunningStats
  field :name,  type: String
  key   :name
  validates_presence_of :name
  embedded_in :application_request
end
