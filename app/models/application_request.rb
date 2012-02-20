class ApplicationRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,  type: String
  field :actions, type: Hash, default: {}
  key   :name
  validates_presence_of :name

  embedded_in :time_bucket

  def update(method_calls)
    method_calls.each_pair do |name, data|
      actions[name] ||= 0
      actions[name] += 1
    end
  end
end
